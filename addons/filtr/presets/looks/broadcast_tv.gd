extends FiltrLookPreset


func _init() -> void:
	display_name = "Broadcast TV"
	description = "Late-night broadcast — warm lift, visible scanlines, tape grain, and mild color fringe."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": 0.06, "contrast": 0.04, "rgb_tint": Vector3(1.05, 1.0, 0.95)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/scanlines.gdshader",
			{"strength": 0.36, "line_spacing": 2.8},
			{"strength": 0.0, "line_spacing": 2.8}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/grain.gdshader",
			{"amount": 0.065},
			{"amount": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/chromatic.gdshader",
			{"strength": 0.007},
			{"strength": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.28, "radius": 0.88},
			{"strength": 0.0, "radius": 0.88}
		),
	]
	sub_controls = [
		{
			"key": "snow",
			"label": "Snow",
			"min": 0.0,
			"max": 1.0,
			"default": 0.45,
			"hint": "Bright specks and tape noise crawling over the picture.",
		},
		{
			"key": "bleed",
			"label": "Bleed",
			"min": 0.0,
			"max": 1.0,
			"default": 0.5,
			"hint": "Colour smear at high-contrast edges, like a weak composite signal.",
		},
	]
	sub_bindings = {
		"snow": [{"layer": 2, "uniform": "amount", "weight": 1.0}],
		"bleed": [{"layer": 3, "uniform": "strength", "weight": 1.0}],
	}
