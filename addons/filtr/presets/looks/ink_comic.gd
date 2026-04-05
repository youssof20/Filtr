extends FiltrLookPreset


func _init() -> void:
	display_name = "Ink & Comic"
	description = "Bold contrast, chunky pixels, and ordered dither — print / indie comic energy."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": -0.05, "contrast": 0.28, "rgb_tint": Vector3(1.0, 1.0, 1.0)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/pixelate.gdshader",
			{"resolution": 420.0},
			{"resolution": 1920.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/dither.gdshader",
			{"strength": 0.35, "pattern": 0},
			{"strength": 0.0, "pattern": 0}
		),
	]
	sub_controls = [
		{
			"key": "chunk",
			"label": "Chunk",
			"min": 0.0,
			"max": 1.0,
			"default": 0.5,
			"hint": "Pixel block size — bigger blocks feel more retro panel.",
		},
		{
			"key": "ink",
			"label": "Ink",
			"min": 0.0,
			"max": 1.0,
			"default": 0.45,
			"hint": "Dither strength — halftone / newsprint texture.",
		},
		{
			"key": "punch",
			"label": "Punch",
			"min": 0.0,
			"max": 1.0,
			"default": 0.55,
			"hint": "Contrast push — harder blacks and carved shapes.",
		},
	]
	sub_bindings = {
		"chunk": [{"layer": 1, "uniform": "resolution", "weight": 1.0}],
		"ink": [{"layer": 2, "uniform": "strength", "weight": 1.0}],
		"punch": [{"layer": 0, "uniform": "contrast", "weight": 1.0}],
	}
