extends FiltrLookPreset


func _init() -> void:
	display_name = "Night Vision"
	description = "Stereotypical green phosphor scope — flat mono lift, tunnel vignette, and noisy scan texture."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": -0.88, "contrast": 0.22, "rgb_tint": Vector3(0.42, 1.02, 0.48)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.52, "radius": 0.74},
			{"strength": 0.0, "radius": 0.74}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/grain.gdshader",
			{"amount": 0.09},
			{"amount": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/scanlines.gdshader",
			{"strength": 0.2, "line_spacing": 2.2},
			{"strength": 0.0, "line_spacing": 2.2}
		),
	]
	sub_controls = [
		{
			"key": "phosphor",
			"label": "Phosphor",
			"min": 0.0,
			"max": 1.0,
			"default": 0.5,
			"hint": "How strong the green tube tint feels — more is closer to classic night-vision fiction.",
		},
		{
			"key": "flicker",
			"label": "Flicker",
			"min": 0.0,
			"max": 1.0,
			"default": 0.35,
			"hint": "Irregular brightness pulsing, like an unstable tube or weak power.",
		},
	]
	sub_bindings = {
		"phosphor": [{"layer": 0, "uniform": "rgb_tint", "weight": 1.0}],
		"flicker": [
			{
				"layer": 0,
				"uniform": "flicker",
				"direct": true,
				"direct_min": 0.0,
				"direct_max": 0.5,
			},
			{
				"layer": 0,
				"uniform": "flicker_speed",
				"direct": true,
				"direct_min": 0.0,
				"direct_max": 32.0,
			},
		],
	}
