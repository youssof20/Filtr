extends FiltrLookPreset


func _init() -> void:
	display_name = "Cold Interrogation"
	description = "Harsh overhead room — drained saturation, icy blue lift, crushing contrast, oppressive vignette."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": -0.48, "contrast": 0.32, "rgb_tint": Vector3(0.88, 0.94, 1.06)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.58, "radius": 0.66},
			{"strength": 0.0, "radius": 0.66}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/grain.gdshader",
			{"amount": 0.035},
			{"amount": 0.0}
		),
	]
	sub_controls = [
		{
			"key": "crunch",
			"label": "Crunch",
			"min": 0.0,
			"max": 1.0,
			"default": 0.55,
			"hint": "Contrast slam — harder mids and more clipped shadows and highlights.",
		},
		{
			"key": "flicker",
			"label": "Flicker",
			"min": 0.0,
			"max": 1.0,
			"default": 0.3,
			"hint": "Harsh fluorescent-style brightness flutter over the whole frame.",
		},
	]
	sub_bindings = {
		"crunch": [{"layer": 0, "uniform": "contrast", "weight": 1.0}],
		"flicker": [
			{
				"layer": 0,
				"uniform": "flicker",
				"direct": true,
				"direct_min": 0.0,
				"direct_max": 0.55,
			},
			{
				"layer": 0,
				"uniform": "flicker_speed",
				"direct": true,
				"direct_min": 0.0,
				"direct_max": 36.0,
			},
		],
	}
