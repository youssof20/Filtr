## Turns FiltrNode sub_values + preset sub_controls/sub_bindings into per-uniform multipliers and direct shader values.
class_name FiltrSubUniformResolver
extends RefCounted


## Returns uniform_scales for FiltrShaderBuilder.apply_intensity (keys "layer:uniform" -> 0..1 multiplier on t).
static func build_uniform_scales(look_id: String, sub_values: Dictionary, preset: FiltrLookPreset) -> Dictionary:
	var scales: Dictionary = {}
	if preset == null or look_id.is_empty():
		return scales
	var bindings: Variant = preset.sub_bindings
	if bindings == null or not bindings is Dictionary:
		return scales
	for key in (bindings as Dictionary).keys():
		var u := _normalized_u(look_id, str(key), sub_values, preset)
		var arr: Variant = (bindings as Dictionary)[key]
		if arr == null or not arr is Array:
			continue
		for item in arr as Array:
			if not item is Dictionary:
				continue
			var b: Dictionary = item
			if b.get("direct", false):
				continue
			var layer: int = int(b.get("layer", -1))
			var un := str(b.get("uniform", ""))
			if layer < 0 or un.is_empty():
				continue
			var w: float = float(b.get("weight", 1.0))
			var mul := lerpf(1.0, u, clampf(w, 0.0, 1.0))
			var map_key := "%d:%s" % [layer, un]
			if scales.has(map_key):
				scales[map_key] = float(scales[map_key]) * mul
			else:
				scales[map_key] = mul
	return scales


## Sets uniforms that bypass intensity lerp (pulse speed, direct strengths, etc.).
static func apply_direct_uniforms(
	materials: Array[ShaderMaterial],
	effect_layers: Array[FiltrEffectLayer],
	look_id: String,
	sub_values: Dictionary,
	preset: FiltrLookPreset,
	intensity_scale: float = 1.0
) -> void:
	var ts := clampf(intensity_scale, 0.0, 1.0)
	if preset == null or look_id.is_empty():
		return
	var bindings: Variant = preset.sub_bindings
	if bindings == null or not bindings is Dictionary:
		return
	for key in (bindings as Dictionary).keys():
		var u := _normalized_u(look_id, str(key), sub_values, preset)
		var arr: Variant = (bindings as Dictionary)[key]
		if arr == null or not arr is Array:
			continue
		for item in arr as Array:
			if not item is Dictionary:
				continue
			var b: Dictionary = item
			if not b.get("direct", false):
				continue
			var layer: int = int(b.get("layer", -1))
			var un := str(b.get("uniform", ""))
			if layer < 0 or un.is_empty() or layer >= materials.size():
				continue
			var dmin: float = float(b.get("direct_min", 0.0))
			var dmax: float = float(b.get("direct_max", 1.0))
			var val := lerpf(dmin, dmax, u) * ts
			var mat: ShaderMaterial = materials[layer]
			if mat:
				mat.set_shader_parameter(un, val)


static func _storage_key(look_id: String, control_key: String) -> String:
	return "%s:%s" % [look_id, control_key]


static func _normalized_u(look_id: String, control_key: String, sub_values: Dictionary, preset: FiltrLookPreset) -> float:
	var def := _control_def(preset, control_key)
	if def.is_empty():
		return 1.0
	var mn: float = float(def.get("min", 0.0))
	var mx: float = float(def.get("max", 1.0))
	if is_equal_approx(mx, mn):
		return 1.0
	var sk := _storage_key(look_id, control_key)
	var raw: float = float(def.get("default", mn))
	if sub_values.has(sk):
		raw = float(sub_values[sk])
	raw = clampf(raw, mn, mx)
	return inverse_lerp(mn, mx, raw)


static func _control_def(preset: FiltrLookPreset, key: String) -> Dictionary:
	for c in preset.sub_controls:
		if c is Dictionary and str((c as Dictionary).get("key", "")) == key:
			return c as Dictionary
	return {}


static func clamp_sub_value_for_key(preset: FiltrLookPreset, look_id: String, key: String, value: float) -> float:
	var def := _control_def(preset, key)
	if def.is_empty():
		return value
	var mn: float = float(def.get("min", 0.0))
	var mx: float = float(def.get("max", 1.0))
	return clampf(value, mn, mx)
