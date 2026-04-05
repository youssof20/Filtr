extends FiltrLookPreset


func _init() -> void:
	display_name = "Security Cam"
	description = "Flat contrast, green monitor tint, blocky compression, scan lines, and light grain."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": -0.35, "contrast": 0.12, "rgb_tint": Vector3(0.75, 1.05, 0.82)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/pixelate.gdshader",
			{"resolution": 140.0},
			{"resolution": 1920.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/scanlines.gdshader",
			{"strength": 0.4, "line_spacing": 3.0},
			{"strength": 0.0, "line_spacing": 3.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/grain.gdshader",
			{"amount": 0.07},
			{"amount": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.3, "radius": 0.9},
			{"strength": 0.0, "radius": 0.9}
		),
	]
	sub_controls = [
		{
			"key": "compression",
			"label": "Compression",
			"min": 0.0,
			"max": 1.0,
			"default": 0.5,
			"hint": "Chunky digital blocks — like a cheap DVR stretching a low-res feed.",
		},
		{
			"key": "noise",
			"label": "Noise",
			"min": 0.0,
			"max": 1.0,
			"default": 0.45,
			"hint": "Snow and static over the picture, typical of a noisy camera chain.",
		},
	]
	sub_bindings = {
		"compression": [{"layer": 1, "uniform": "resolution", "weight": 1.0}],
		"noise": [{"layer": 3, "uniform": "amount", "weight": 1.0}],
	}
