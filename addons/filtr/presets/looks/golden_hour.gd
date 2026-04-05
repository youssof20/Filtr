extends FiltrLookPreset


func _init() -> void:
	display_name = "Golden Hour"
	description = "Warm late-sun grade, gentle vignette, and a touch of glowy haze."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": 0.12, "contrast": -0.06, "rgb_tint": Vector3(1.06, 1.02, 0.94)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.38, "radius": 0.88},
			{"strength": 0.0, "radius": 0.88}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/blur.gdshader",
			{"radius": 0.55},
			{"radius": 0.0}
		),
	]
	sub_controls = [
		{
			"key": "warmth",
			"label": "Warmth",
			"min": 0.0,
			"max": 1.0,
			"default": 0.55,
			"hint": "How strong the amber / peach cast feels.",
		},
		{
			"key": "sun",
			"label": "Sun falloff",
			"min": 0.0,
			"max": 1.0,
			"default": 0.5,
			"hint": "Edge darkening — like the frame catching less light.",
		},
		{
			"key": "haze",
			"label": "Haze",
			"min": 0.0,
			"max": 1.0,
			"default": 0.4,
			"hint": "Soft bloom-like diffusion from the light blur pass.",
		},
	]
	sub_bindings = {
		"warmth": [{"layer": 0, "uniform": "saturation", "weight": 1.0}],
		"sun": [{"layer": 1, "uniform": "strength", "weight": 1.0}],
		"haze": [{"layer": 2, "uniform": "radius", "weight": 1.0}],
	}
