extends FiltrLookPreset


func _init() -> void:
	display_name = "Dreamcore"
	description = "Soft glow, pastel lift, subtle chromatic drift, and a gentle warp."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/blur.gdshader",
			{"radius": 1.2},
			{"radius": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/chromatic.gdshader",
			{"strength": 0.006},
			{"strength": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": 0.14, "contrast": -0.04, "rgb_tint": Vector3(1.04, 0.98, 1.08)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/warp.gdshader",
			{"strength": 0.014},
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
			"key": "haze",
			"label": "Haze",
			"min": 0.0,
			"max": 1.0,
			"default": 0.55,
			"hint": "Soft bloom that smears detail like memory or half-sleep.",
		},
		{
			"key": "tint",
			"label": "Tint",
			"min": 0.0,
			"max": 1.0,
			"default": 0.5,
			"hint": "How strong the pastel colour wash feels across the whole frame.",
		},
		{
			"key": "drift",
			"label": "Drift",
			"min": 0.0,
			"max": 1.0,
			"default": 0.35,
			"hint": "Wave warp — how much the image swims (was always on before; now you can dial it down).",
		},
	]
	sub_bindings = {
		"haze": [{"layer": 0, "uniform": "radius", "weight": 1.0}],
		"tint": [{"layer": 2, "uniform": "rgb_tint", "weight": 1.0}],
		"drift": [{"layer": 3, "uniform": "strength", "weight": 1.0}],
	}
