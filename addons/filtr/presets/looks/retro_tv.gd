extends FiltrLookPreset


func _init() -> void:
	display_name = "Retro TV"
	description = "Curved glass CRT fantasy — barrel warp, scan-line dimming, rainbow fringe, and living-room vignette."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/crt_warp.gdshader",
			{"bend_amount": 0.48, "line_strength": 0.42},
			{"bend_amount": 0.0, "line_strength": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/chromatic.gdshader",
			{"strength": 0.011},
			{"strength": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.34, "radius": 0.82},
			{"strength": 0.0, "radius": 0.8}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/grain.gdshader",
			{"amount": 0.055},
			{"amount": 0.0}
		),
	]
	sub_controls = [
		{
			"key": "bend",
			"label": "Bend",
			"min": 0.0,
			"max": 1.0,
			"default": 0.55,
			"hint": "How curved the screen glass feels — stronger barrel like a deep CRT.",
		},
		{
			"key": "fringe",
			"label": "Fringe",
			"min": 0.0,
			"max": 1.0,
			"default": 0.5,
			"hint": "Rainbow colour split — chromatic aberration separate from scan lines.",
		},
	]
	sub_bindings = {
		"bend": [{"layer": 0, "uniform": "bend_amount", "weight": 1.0}],
		"fringe": [
			{"layer": 0, "uniform": "line_strength", "weight": 1.0},
			{"layer": 1, "uniform": "strength", "weight": 0.85},
		],
	}
