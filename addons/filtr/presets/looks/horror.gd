extends FiltrLookPreset


func _init() -> void:
	display_name = "Horror"
	description = "Drained color, heavy vignette, grain, and a touch of uneasy distortion."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": -0.38, "contrast": 0.15, "rgb_tint": Vector3(0.92, 0.88, 0.95)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.52, "radius": 0.72},
			{"strength": 0.0, "radius": 0.68}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/grain.gdshader",
			{"amount": 0.09},
			{"amount": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/noise_distort.gdshader",
			{"strength": 0.013},
			{"strength": 0.0}
		),
	]
	sub_controls = [
		{
			"key": "grain",
			"label": "Grain",
			"min": 0.0,
			"max": 1.0,
			"default": 0.5,
			"hint": "Film-like grit and texture across the frame.",
		},
		{
			"key": "crawl",
			"label": "Crawl",
			"min": 0.0,
			"max": 1.0,
			"default": 0.35,
			"hint": "How much the dark edges seem to breathe and pulse — unsettling, slow movement.",
		},
	]
	sub_bindings = {
		"grain": [{"layer": 2, "uniform": "amount", "weight": 1.0}],
		"crawl": [
			{
				"layer": 1,
				"uniform": "pulse_speed",
				"direct": true,
				"direct_min": 0.0,
				"direct_max": 14.0,
			},
			{
				"layer": 1,
				"uniform": "pulse_amount",
				"direct": true,
				"direct_min": 0.0,
				"direct_max": 0.7,
			},
		],
	}
