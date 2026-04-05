@icon("res://addons/filtr/icons/filtr_node.svg")
class_name FiltrNode
extends Node

signal filtr_changed

var _look: String = ""
var _intensity: float = 100.0
var _sub_values: Dictionary = {}
## Loaded from older scenes; merged into `sub_values` on enter tree.
var _legacy_sub_slider_values: Dictionary = {}
var _legacy_migration_done: bool = false
var _adjust_hue: float = 0.0
var _adjust_saturation: float = 0.0
var _adjust_shadow_tint: Color = Color(1, 1, 1, 1)
var _adjust_highlight: float = 0.0
var _adjust_shadow_strength: float = 65.0


@export var look: String = "":
	get:
		return _look
	set(value):
		if _look == value:
			return
		_look = value
		if Engine.is_editor_hint():
			notify_property_list_changed()
			filtr_changed.emit()
		_notify_manager()


@export_range(0.0, 100.0, 0.1) var intensity: float = 100.0:
	get:
		return _intensity
	set(value):
		var v := clampf(value, 0.0, 100.0)
		if is_equal_approx(_intensity, v):
			return
		_intensity = v
		_notify_intensity_only()


## Keys "{look_id}:{control_key}" -> stored value in each control's min..max range.
@export var sub_values: Dictionary:
	get:
		return _sub_values
	set(value):
		_sub_values = value.duplicate(true) if value != null else {}
		if Engine.is_editor_hint():
			filtr_changed.emit()
		if not Engine.is_editor_hint():
			FiltrManager.sync_intensity_from_driver()


## Deprecated: pre-1.0 scenes only. Merged into `sub_values` automatically.
@export var sub_slider_values: Dictionary:
	get:
		return _legacy_sub_slider_values
	set(value):
		_legacy_sub_slider_values = value.duplicate(true) if value != null else {}


@export_group("Adjust (global)")
@export_range(-180.0, 180.0, 1.0) var adjust_hue: float = 0.0:
	get:
		return _adjust_hue
	set(value):
		if is_equal_approx(_adjust_hue, value):
			return
		_adjust_hue = value
		_notify_adjust_changed()


@export_range(-50.0, 50.0, 0.5) var adjust_saturation: float = 0.0:
	get:
		return _adjust_saturation
	set(value):
		if is_equal_approx(_adjust_saturation, value):
			return
		_adjust_saturation = value
		_notify_adjust_changed()


## Multiplies darker pixels (lift cool/warm in shadows). Default white = no change.
@export var adjust_shadow_tint: Color = Color(1, 1, 1, 1):
	get:
		return _adjust_shadow_tint
	set(value):
		if _adjust_shadow_tint == value:
			return
		_adjust_shadow_tint = value
		_notify_adjust_changed()


## How strongly the shadow tint is applied to darker areas (global grade, not scene lights).
@export_range(0.0, 100.0, 1.0) var adjust_shadow_strength: float = 65.0:
	get:
		return _adjust_shadow_strength
	set(value):
		var v := clampf(value, 0.0, 100.0)
		if is_equal_approx(_adjust_shadow_strength, v):
			return
		_adjust_shadow_strength = v
		_notify_adjust_changed()


@export_range(0.0, 50.0, 0.5) var adjust_highlight: float = 0.0:
	get:
		return _adjust_highlight
	set(value):
		if is_equal_approx(_adjust_highlight, value):
			return
		_adjust_highlight = value
		_notify_adjust_changed()


func _validate_property(property: Dictionary) -> void:
	var n: StringName = property.get("name", &"")
	if n == &"sub_values" or n == &"sub_slider_values":
		property["usage"] = PROPERTY_USAGE_STORAGE


func _enter_tree() -> void:
	_run_legacy_sub_migration()


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	FiltrManager.register_driver(self)


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	FiltrManager.unregister_driver(self)


func _run_legacy_sub_migration() -> void:
	if _legacy_migration_done:
		return
	_legacy_migration_done = true
	if _legacy_sub_slider_values.is_empty():
		return
	var merged := _sub_values.duplicate(true)
	for sk in _legacy_sub_slider_values.keys():
		var key_str := str(sk)
		var parts := key_str.split(":")
		if parts.size() != 2:
			continue
		var look_id := parts[0]
		var ctrl_key := parts[1]
		var old_pct := float(_legacy_sub_slider_values[sk])
		var preset := FiltrPresetRegistry.instantiate_preset(look_id)
		var converted := clampf(old_pct / 100.0, 0.0, 1.0)
		if preset != null:
			for c in preset.sub_controls:
				if c is Dictionary and str((c as Dictionary).get("key", "")) == ctrl_key:
					var mn := float((c as Dictionary).get("min", 0.0))
					var mx := float((c as Dictionary).get("max", 1.0))
					converted = lerpf(mn, mx, clampf(old_pct / 100.0, 0.0, 1.0))
					break
		merged[key_str] = converted
	_sub_values = merged
	_legacy_sub_slider_values = {}
	if Engine.is_editor_hint():
		notify_property_list_changed()
	else:
		FiltrManager.sync_intensity_from_driver()


## Instantly applies a look using its display name or id (for example "PS1").
## Safe to call from AnimationPlayer method tracks.
func set_look(preset_label: String) -> void:
	look = FiltrPresetRegistry.label_to_id(preset_label)


## Same as setting `look` to a built-in id string (no display-name resolution). Safe for AnimationPlayer method tracks.
func snap_to_look(preset_id: String) -> void:
	look = preset_id.strip_edges()


## Updates the stored look without notifying the manager (used after tweens).
func filtr_internal_set_look(id: String) -> void:
	_look = id


## Eases in a look over the given time in seconds. Safe to call from AnimationPlayer method tracks.
func transition_to(preset_label: String, duration: float) -> void:
	var id := FiltrPresetRegistry.label_to_id(preset_label)
	if Engine.is_editor_hint():
		return
	filtr_internal_set_look(id)
	FiltrManager.transition_to_preset(id, duration)


## Fades the look out across the given time in seconds. Safe to call from AnimationPlayer method tracks.
func clear(duration: float = 0.0) -> void:
	if Engine.is_editor_hint():
		return
	FiltrManager.clear_look(duration)


## Sets strength from 0.0 (off) to 1.0 (full). Safe to call from AnimationPlayer method tracks.
func set_intensity(value: float) -> void:
	_intensity = clampf(value, 0.0, 1.0) * 100.0
	_notify_intensity_only()


## Sets a detail control for the **current** look by `key` (see each look’s tuning list). Value is clamped to that control’s range. Safe to call from AnimationPlayer method tracks.
func set_sub_value(key: String, value: float) -> void:
	if look.is_empty():
		return
	var preset := FiltrPresetRegistry.instantiate_preset(look)
	if preset == null:
		return
	var v := FiltrSubUniformResolver.clamp_sub_value_for_key(preset, look, key, value)
	var sk := "%s:%s" % [look, key]
	var d := sub_values.duplicate(true)
	d[sk] = v
	sub_values = d


## Back-compat: `percent` was 0–100 on the old uniform scale. Interpreted as normalized position in the control’s min..max.
func set_look_tuning(slider_id: String, percent: float) -> void:
	if look.is_empty():
		return
	var preset := FiltrPresetRegistry.instantiate_preset(look)
	if preset == null:
		return
	var u := clampf(percent / 100.0, 0.0, 1.0)
	for c in preset.sub_controls:
		if c is Dictionary and str((c as Dictionary).get("key", "")) == slider_id:
			var mn := float((c as Dictionary).get("min", 0.0))
			var mx := float((c as Dictionary).get("max", 1.0))
			set_sub_value(slider_id, lerpf(mn, mx, u))
			return


func _notify_manager() -> void:
	if Engine.is_editor_hint():
		return
	FiltrManager.apply_from_driver()


func _notify_intensity_only() -> void:
	if Engine.is_editor_hint():
		filtr_changed.emit()
		return
	FiltrManager.sync_intensity_from_driver()


func _notify_adjust_changed() -> void:
	if Engine.is_editor_hint():
		filtr_changed.emit()
		return
	FiltrManager.sync_adjust_from_driver()
