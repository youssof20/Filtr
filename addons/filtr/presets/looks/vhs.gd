extends FiltrLookPreset


func _init() -> void:
	display_name = "VHS"
	description = "Tape-era softness, scan lines, chromatic fringing, and a little grain."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/chromatic.gdshader",
			{"strength": 0.0095},
			{"strength": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/blur.gdshader",
			{"radius": 0.62},
			{"radius": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/scanlines.gdshader",
			{"strength": 0.32, "line_spacing": 2.5},
			{"strength": 0.0, "line_spacing": 2.5}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/grain.gdshader",
			{"amount": 0.08},
			{"amount": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.28, "radius": 0.82},
			{"strength": 0.0, "radius": 0.82}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": -0.08, "contrast": 0.05, "rgb_tint": Vector3(1.02, 1.0, 0.98)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
	]
	sub_controls = [
		{
			"key": "tracking",
			"label": "Tracking",
			"min": 0.0,
			"max": 1.0,
			"default": 0.55,
			"hint": "Colour fringing and misalignment, like a tape head slightly off centre.",
		},
		{
			"key": "static",
			"label": "Static",
			"min": 0.0,
			"max": 1.0,
			"default": 0.45,
			"hint": "Animated grain and noise crawling over the image.",
		},
	]
	sub_bindings = {
		"tracking": [{"layer": 0, "uniform": "strength", "weight": 1.0}],
		"static": [{"layer": 3, "uniform": "amount", "weight": 1.0}],
	}
