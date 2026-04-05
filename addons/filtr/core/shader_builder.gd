class_name FiltrShaderBuilder
extends RefCounted

## Each pass is a fullscreen ColorRect. BackBufferCopy between passes makes SCREEN_TEXTURE read the previous composite (popup layer uses 1025 on the CanvasLayer that owns this stack).


func clear_stack(container: Node) -> void:
	while container.get_child_count() > 0:
		var c: Node = container.get_child(0)
		container.remove_child(c)
		c.free()


func rebuild_stack(container: CanvasLayer, layers: Array[FiltrEffectLayer]) -> Array[ShaderMaterial]:
	clear_stack(container)
	var materials: Array[ShaderMaterial] = []
	var index := 0
	for layer in layers:
		var shad: Shader = load(layer.shader_path) as Shader
		if shad == null:
			FiltrLog.event("could not load shader at %s" % layer.shader_path)
			clear_stack(container)
			return []
		if index > 0:
			var bbc := BackBufferCopy.new()
			bbc.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
			container.add_child(bbc)
		var rect := ColorRect.new()
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		rect.offset_left = 0.0
		rect.offset_top = 0.0
		rect.offset_right = 0.0
		rect.offset_bottom = 0.0
		var mat := ShaderMaterial.new()
		mat.shader = shad
		rect.material = mat
		container.add_child(rect)
		materials.append(mat)
		index += 1
	return materials


## Adds one fullscreen pass after a BackBufferCopy (stack already has at least one pass).
func append_screen_pass(container: CanvasLayer, shader: Shader) -> ShaderMaterial:
	var bbc := BackBufferCopy.new()
	bbc.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	container.add_child(bbc)
	var rect := ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.offset_left = 0.0
	rect.offset_top = 0.0
	rect.offset_right = 0.0
	rect.offset_bottom = 0.0
	var mat := ShaderMaterial.new()
	mat.shader = shader
	rect.material = mat
	container.add_child(rect)
	return mat


## uniform_scales: keys "layer_index:uniform_name" -> 0..1 multiplier on t for that uniform (default 1).
static func apply_intensity(
	materials: Array[ShaderMaterial],
	layers: Array[FiltrEffectLayer],
	t: float,
	uniform_scales: Dictionary = {}
) -> void:
	var tt := clampf(t, 0.0, 1.0)
	var n: int = mini(materials.size(), layers.size())
	for i in n:
		var mat: ShaderMaterial = materials[i]
		var layer: FiltrEffectLayer = layers[i]
		for key in layer.base_params.keys():
			var b: Variant = layer.base_params[key]
			var z: Variant = layer.zero_params.get(key, b)
			var map_key := "%d:%s" % [i, str(key)]
			var mul := 1.0
			if uniform_scales.has(map_key):
				mul = clampf(float(uniform_scales[map_key]), 0.0, 1.0)
			var te := tt * mul
			mat.set_shader_parameter(key, _lerp_uniform(z, b, te))


static func _lerp_uniform(a: Variant, b: Variant, t: float) -> Variant:
	if a is float and b is float:
		return lerpf(float(a), float(b), t)
	if a is int and b is int:
		return int(round(lerpf(float(a), float(b), t)))
	if a is Color and b is Color:
		return (a as Color).lerp(b as Color, t)
	if a is Vector2 and b is Vector2:
		return (a as Vector2).lerp(b as Vector2, t)
	if a is Vector3 and b is Vector3:
		return (a as Vector3).lerp(b as Vector3, t)
	return b
