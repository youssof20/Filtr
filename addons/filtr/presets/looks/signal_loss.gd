extends FiltrLookPreset


func _init() -> void:
	display_name = "Signal Loss"
	description = "Digital breakup — wobbly noise field, aggressive chromatic split, and thin scan interference."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/noise_distort.gdshader",
			{"strength": 0.024},
			{"strength": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/chromatic.gdshader",
			{"strength": 0.01},
			{"strength": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/scanlines.gdshader",
			{"strength": 0.18, "line_spacing": 3.0},
			{"strength": 0.0, "line_spacing": 3.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.25, "radius": 0.88},
			{"strength": 0.0, "radius": 0.88}
		),
	]
	sub_controls = [
		{
			"key": "tear",
			"label": "Tear",
			"min": 0.0,
			"max": 1.0,
			"default": 0.55,
			"hint": "Noisy warping and breakup — like a satellite dish in heavy weather.",
		},
		{
			"key": "split",
			"label": "Split",
			"min": 0.0,
			"max": 1.0,
			"default": 0.5,
			"hint": "How far RGB channels slide apart — harsher digital corruption.",
		},
	]
	sub_bindings = {
		"tear": [{"layer": 0, "uniform": "strength", "weight": 1.0}],
		"split": [{"layer": 1, "uniform": "strength", "weight": 1.0}],
	}
