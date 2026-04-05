extends FiltrLookPreset


func _init() -> void:
	display_name = "Sun Bleached"
	description = "High-noon haze — pumped warm highlights, bleached mids, dust in the air, and a sun-fried vignette."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": 0.22, "contrast": 0.06, "rgb_tint": Vector3(1.08, 1.02, 0.9)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/blur.gdshader",
			{"radius": 0.35},
			{"radius": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/grain.gdshader",
			{"amount": 0.07},
			{"amount": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.32, "radius": 0.85},
			{"strength": 0.0, "radius": 0.85}
		),
	]
	sub_controls = [
		{
			"key": "haze",
			"label": "Haze",
			"min": 0.0,
			"max": 1.0,
			"default": 0.45,
			"hint": "Heat shimmer and soft diffusion — bleached, overbright afternoon.",
		},
		{
			"key": "dust",
			"label": "Dust",
			"min": 0.0,
			"max": 1.0,
			"default": 0.5,
			"hint": "Particles in the air — gritty sparkle in the highlights.",
		},
	]
	sub_bindings = {
		"haze": [{"layer": 1, "uniform": "radius", "weight": 1.0}],
		"dust": [{"layer": 2, "uniform": "amount", "weight": 1.0}],
	}
