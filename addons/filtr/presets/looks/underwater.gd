extends FiltrLookPreset


func _init() -> void:
	display_name = "Underwater"
	description = "Cool teal cast, soft diffusion, chromatic fringe, ripple warp, and a heavy underwater vignette."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/blur.gdshader",
			{"radius": 1.05},
			{"radius": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": -0.12, "contrast": 0.06, "rgb_tint": Vector3(0.72, 0.95, 1.08)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/chromatic.gdshader",
			{"strength": 0.009},
			{"strength": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/warp.gdshader",
			{"strength": 0.028},
			{"strength": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.5, "radius": 0.7},
			{"strength": 0.0, "radius": 0.7}
		),
	]
	sub_controls = [
		{
			"key": "depth",
			"label": "Depth",
			"min": 0.0,
			"max": 1.0,
			"default": 0.5,
			"hint": "How deep and teal the colour cast feels — more reads colder and more submerged.",
		},
		{
			"key": "ripple",
			"label": "Ripple",
			"min": 0.0,
			"max": 1.0,
			"default": 0.45,
			"hint": "Gentle wobble in the image, like light bending through moving water.",
		},
	]
	sub_bindings = {
		"depth": [{"layer": 1, "uniform": "rgb_tint", "weight": 1.0}],
		"ripple": [{"layer": 3, "uniform": "strength", "weight": 1.0}],
	}
