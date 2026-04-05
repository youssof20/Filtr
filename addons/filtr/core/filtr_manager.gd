extends Node


static func _filter_effect_layers(src: Array[FiltrEffectLayer]) -> Array[FiltrEffectLayer]:
	var out: Array[FiltrEffectLayer] = []
	for l in src:
		if l.shader_path.is_empty():
			continue
		if ResourceLoader.exists(l.shader_path):
			out.append(l)
		else:
			FiltrLog.event("shader missing: %s" % l.shader_path)
	return out

var _canvas: CanvasLayer
var _shader_builder: FiltrShaderBuilder
var _materials: Array[ShaderMaterial] = []
var _effect_layers: Array[FiltrEffectLayer] = []
var _runner: FiltrTransitionRunner
var _active_tween: Tween
var _intensity01: float = 1.0
var _driver: FiltrNode = null
var _zones: Array[Node] = []
## Look id currently driving the built shader stack (driver or zone preset).
var _stack_look_id: String = ""
var _active_preset: FiltrLookPreset = null
var _adjust_material: ShaderMaterial = null

const _CANVAS_LAYER := 1025
const _ADJUST_SHADER := "res://addons/filtr/shaders/adjust_grade.gdshader"


func _ready() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = _CANVAS_LAYER
	_canvas.name = "FiltrPostStack"
	add_child(_canvas)
	_shader_builder = FiltrShaderBuilder.new()
	_runner = FiltrTransitionRunner.new(self)


func _kill_tween() -> void:
	if _active_tween != null and is_instance_valid(_active_tween):
		_active_tween.kill()
	_active_tween = null


func _append_adjust_pass() -> void:
	_adjust_material = null
	if _materials.is_empty():
		return
	var sh: Shader = load(_ADJUST_SHADER) as Shader
	if sh == null:
		return
	_adjust_material = _shader_builder.append_screen_pass(_canvas, sh)


func _apply_adjust_from_driver() -> void:
	if _adjust_material == null:
		return
	if _driver != null:
		_adjust_material.set_shader_parameter("hue_degrees", _driver.adjust_hue)
		_adjust_material.set_shader_parameter("saturation_add", _driver.adjust_saturation / 100.0)
		var st: Color = _driver.adjust_shadow_tint
		_adjust_material.set_shader_parameter("shadow_tint_rgb", Vector3(st.r, st.g, st.b))
		_adjust_material.set_shader_parameter(
			"shadow_mix", clampf(_driver.adjust_shadow_strength / 100.0, 0.0, 1.0)
		)
		_adjust_material.set_shader_parameter(
			"highlight_boost", clampf(_driver.adjust_highlight / 100.0, 0.0, 1.0)
		)
	else:
		_adjust_material.set_shader_parameter("hue_degrees", 0.0)
		_adjust_material.set_shader_parameter("saturation_add", 0.0)
		_adjust_material.set_shader_parameter("shadow_tint_rgb", Vector3(1, 1, 1))
		_adjust_material.set_shader_parameter("shadow_mix", 0.65)
		_adjust_material.set_shader_parameter("highlight_boost", 0.0)
	_adjust_material.set_shader_parameter("adjust_blend", _intensity01)


func _apply_intensity_with_subs(t: float) -> void:
	var sub_dict: Dictionary = {}
	if _driver != null:
		sub_dict = _driver.sub_values
	var scales := FiltrSubUniformResolver.build_uniform_scales(_stack_look_id, sub_dict, _active_preset)
	FiltrShaderBuilder.apply_intensity(_materials, _effect_layers, t, scales)
	if _active_preset != null:
		FiltrSubUniformResolver.apply_direct_uniforms(
			_materials, _effect_layers, _stack_look_id, sub_dict, _active_preset, t
		)
	_apply_adjust_from_driver()


## Rebuilds the fullscreen shader stack from the active FiltrNode’s look and intensity.
func apply_from_driver() -> void:
	if not _zones.is_empty():
		return
	_kill_tween()
	if _driver == null:
		return
	var id: String = _driver.look
	_intensity01 = clampf(_driver.intensity / 100.0, 0.0, 1.0)
	if id.is_empty():
		_stack_look_id = ""
		_active_preset = null
		_adjust_material = null
		_shader_builder.clear_stack(_canvas)
		_materials.clear()
		_effect_layers.clear()
		FiltrLog.event("cleared stack (no look)")
		return
	var preset: FiltrLookPreset = FiltrPresetRegistry.instantiate_preset(id)
	if preset == null:
		_stack_look_id = ""
		_active_preset = null
		_adjust_material = null
		_shader_builder.clear_stack(_canvas)
		_materials.clear()
		_effect_layers.clear()
		return
	_effect_layers = _filter_effect_layers(preset.effects.duplicate())
	if _effect_layers.is_empty():
		_stack_look_id = ""
		_active_preset = null
		_adjust_material = null
		_shader_builder.clear_stack(_canvas)
		_materials.clear()
		_effect_layers.clear()
		return
	_active_preset = preset
	_materials = _shader_builder.rebuild_stack(_canvas, _effect_layers)
	_stack_look_id = id
	_append_adjust_pass()
	_apply_intensity_with_subs(_intensity01)
	FiltrLog.event("apply look=%s intensity=%.2f" % [id, _intensity01])


## Connects a FiltrNode so its look and intensity drive the post stack.
func register_driver(node: FiltrNode) -> void:
	_driver = node
	if _zones.is_empty():
		apply_from_driver()


## Disconnects a FiltrNode and tears down the post stack when it leaves the tree.
func unregister_driver(node: FiltrNode) -> void:
	if _driver != node:
		return
	_driver = null
	_kill_tween()
	if _zones.is_empty():
		_stack_look_id = ""
		_active_preset = null
		_adjust_material = null
		_shader_builder.clear_stack(_canvas)
		_materials.clear()
		_effect_layers.clear()
	else:
		_apply_top_zone_look(0.0)


func zone_body_entered(zone: Node) -> void:
	if zone in _zones:
		return
	_zones.append(zone)
	_sort_zones_by_priority()
	_apply_top_zone_look(_zone_blend_duration(zone))
	FiltrLog.event("zone enter count=%d" % _zones.size())


func zone_body_exited(zone: Node) -> void:
	if not zone in _zones:
		return
	var blend: float = _zone_blend_duration(zone)
	_zones.erase(zone)
	if _zones.is_empty():
		if _zone_exits_clearing_look(zone):
			clear_look(blend)
		else:
			_restore_driver_look(blend)
	else:
		_sort_zones_by_priority()
		_apply_top_zone_look(blend)
	FiltrLog.event("zone exit remaining=%d" % _zones.size())


func _zone_exits_clearing_look(zone: Node) -> bool:
	if zone is FiltrZone:
		return (zone as FiltrZone).on_exit == FiltrZone.OnZoneExit.CLEAR
	if zone is FiltrZone2D:
		return (zone as FiltrZone2D).on_exit == FiltrZone2D.OnZoneExit.CLEAR
	return false


func _zone_blend_duration(zone: Node) -> float:
	if zone is FiltrZone:
		return clampf((zone as FiltrZone).blend_duration, 0.0, 3.0)
	if zone is FiltrZone2D:
		return clampf((zone as FiltrZone2D).blend_duration, 0.0, 3.0)
	return 0.5


func _zone_priority(zone: Node) -> int:
	if zone is FiltrZone:
		return (zone as FiltrZone).filtr_priority
	if zone is FiltrZone2D:
		return (zone as FiltrZone2D).filtr_priority
	return 0


func _zone_look(zone: Node) -> String:
	if zone is FiltrZone:
		return (zone as FiltrZone).look
	if zone is FiltrZone2D:
		return (zone as FiltrZone2D).look
	return ""


func _sort_zones_by_priority() -> void:
	_zones.sort_custom(
		func(a: Node, b: Node) -> bool:
			var pa := _zone_priority(a)
			var pb := _zone_priority(b)
			if pa != pb:
				return pa > pb
			return a.get_instance_id() < b.get_instance_id()
	)


func _apply_top_zone_look(blend: float) -> void:
	if _zones.is_empty():
		return
	var id: String = _zone_look(_zones[0])
	if id.is_empty():
		_restore_driver_look(blend)
	else:
		transition_to_preset(id, blend)


func _restore_driver_look(blend: float) -> void:
	if _driver == null or _driver.look.is_empty():
		clear_look(blend)
		return
	transition_to_preset(_driver.look, blend)


func sync_intensity_from_driver() -> void:
	if _driver == null or _materials.is_empty():
		return
	_intensity01 = clampf(_driver.intensity / 100.0, 0.0, 1.0)
	_apply_intensity_with_subs(_intensity01)


func sync_adjust_from_driver() -> void:
	if _adjust_material == null or _materials.is_empty():
		return
	_apply_adjust_from_driver()


func transition_to_preset(preset_id: String, duration: float) -> void:
	_kill_tween()
	if preset_id.is_empty():
		return
	FiltrLog.event("transition look=%s duration=%.2fs" % [preset_id, duration])
	var preset: FiltrLookPreset = FiltrPresetRegistry.instantiate_preset(preset_id)
	if preset == null:
		_stack_look_id = ""
		_active_preset = null
		_adjust_material = null
		_shader_builder.clear_stack(_canvas)
		_materials.clear()
		_effect_layers.clear()
		return
	_effect_layers = _filter_effect_layers(preset.effects.duplicate())
	if _effect_layers.is_empty():
		_stack_look_id = ""
		_active_preset = null
		_adjust_material = null
		_shader_builder.clear_stack(_canvas)
		_materials.clear()
		_effect_layers.clear()
		return
	_active_preset = preset
	_materials = _shader_builder.rebuild_stack(_canvas, _effect_layers)
	_stack_look_id = preset_id
	_append_adjust_pass()
	var target := 1.0
	if _driver:
		target = clampf(_driver.intensity / 100.0, 0.0, 1.0)
	_intensity01 = target
	_apply_intensity_with_subs(0.0)
	var on_step := func(t: float) -> void:
		_apply_intensity_with_subs(t)
	_active_tween = _runner.tween_float(duration, 0.0, target, on_step)


func clear_look(duration: float = 0.0) -> void:
	_kill_tween()
	if _materials.is_empty():
		_stack_look_id = ""
		_active_preset = null
		if _driver:
			_driver.filtr_internal_set_look("")
		_adjust_material = null
		_shader_builder.clear_stack(_canvas)
		return
	FiltrLog.event("clear_look duration=%.2fs" % duration)
	if duration <= 0.0:
		_apply_intensity_with_subs(0.0)
		_stack_look_id = ""
		_active_preset = null
		_adjust_material = null
		_shader_builder.clear_stack(_canvas)
		_materials.clear()
		_effect_layers.clear()
		if _driver:
			_driver.filtr_internal_set_look("")
		_intensity01 = 0.0
		return
	var start := _intensity01
	var on_step := func(t: float) -> void:
		_apply_intensity_with_subs(t)
		_intensity01 = t
	_active_tween = _runner.tween_float(duration, start, 0.0, on_step)
	if _active_tween:
		_active_tween.finished.connect(
			func() -> void:
				_stack_look_id = ""
				_active_preset = null
				_adjust_material = null
				_shader_builder.clear_stack(_canvas)
				_materials.clear()
				_effect_layers.clear()
				if _driver:
					_driver.filtr_internal_set_look("")
				_intensity01 = 0.0,
			CONNECT_ONE_SHOT
		)


func set_intensity01(value: float) -> void:
	_intensity01 = clampf(value, 0.0, 1.0)
	if _driver:
		_driver.intensity = _intensity01 * 100.0
	_apply_intensity_with_subs(_intensity01)
