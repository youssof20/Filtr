extends FiltrLookPreset


func _init() -> void:
	display_name = "Neon Night"
	description = "Punchy color, mild chromatic split, scanlines, and a tight vignette — city / synthwave energy."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": 0.34, "contrast": 0.1, "rgb_tint": Vector3(1.05, 0.96, 1.12)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/chromatic.gdshader",
			{"strength": 0.009},
			{"strength": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/scanlines.gdshader",
			{"strength": 0.17, "line_spacing": 2.5},
			{"strength": 0.0, "line_spacing": 2.5}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.38, "radius": 0.78},
			{"strength": 0.0, "radius": 0.78}
		),
	]
	sub_controls = [
		{
			"key": "punch",
			"label": "Punch",
			"min": 0.0,
			"max": 1.0,
			"default": 0.55,
			"hint": "Neon colour saturation — more electric signs and less natural skin.",
		},
		{
			"key": "fringe",
			"label": "Fringe",
			"min": 0.0,
			"max": 1.0,
			"default": 0.45,
			"hint": "RGB split at edges — cheap lens / prism vibes.",
		},
		{
			"key": "lines",
			"label": "Lines",
			"min": 0.0,
			"max": 1.0,
			"default": 0.4,
			"hint": "Horizontal scan lines like a CRT or low-res LED wall.",
		},
	]
	sub_bindings = {
		"punch": [{"layer": 0, "uniform": "saturation", "weight": 1.0}],
		"fringe": [{"layer": 1, "uniform": "strength", "weight": 1.0}],
		"lines": [{"layer": 2, "uniform": "strength", "weight": 1.0}],
	}
