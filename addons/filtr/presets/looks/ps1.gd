extends FiltrLookPreset


func _init() -> void:
	display_name = "PS1"
	description = "Classic PlayStation 1 look — chunky pixels, dithering, slightly muted color, and a touch of wobble."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/dither.gdshader",
			{"strength": 0.8, "pattern": 0},
			{"strength": 0.0, "pattern": 0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/pixelate.gdshader",
			{"resolution": 320.0},
			{"resolution": 1920.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": -0.15, "contrast": 0.1, "rgb_tint": Vector3(1.0, 1.0, 1.0)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/warp.gdshader",
			{"strength": 0.03},
			{"strength": 0.0}
		),
	]
	sub_controls = [
		{
			"key": "wobble",
			"label": "Wobble",
			"min": 0.0,
			"max": 1.0,
			"default": 0.55,
			"hint": "How much the picture bends and shimmers at the edges, like an unsteady console output.",
		},
		{
			"key": "dither",
			"label": "Dither",
			"min": 0.0,
			"max": 1.0,
			"default": 0.6,
			"hint": "Extra visible stepping between similar colours — higher reads crunchier and more retro.",
		},
	]
	sub_bindings = {
		"wobble": [{"layer": 3, "uniform": "strength", "weight": 1.0}],
		"dither": [{"layer": 0, "uniform": "strength", "weight": 1.0}],
	}
