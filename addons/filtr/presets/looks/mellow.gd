extends FiltrLookPreset


func _init() -> void:
	display_name = "Mellow"
	description = "Soft blur, gentle desaturation, warm lift, and a light vignette — easy on the eyes."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/blur.gdshader",
			{"radius": 0.75},
			{"radius": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": -0.18, "contrast": -0.06, "rgb_tint": Vector3(1.04, 1.02, 0.97)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.2, "radius": 0.9},
			{"strength": 0.0, "radius": 0.9}
		),
	]
	sub_controls = [
		{
			"key": "haze",
			"label": "Haze",
			"min": 0.0,
			"max": 1.0,
			"default": 0.5,
			"hint": "Overall softness — dreamier, less sharp detail.",
		},
		{
			"key": "warmth",
			"label": "Warmth",
			"min": 0.0,
			"max": 1.0,
			"default": 0.45,
			"hint": "How cosy the colour cast feels — more amber, less cold grey.",
		},
		{
			"key": "fade",
			"label": "Fade",
			"min": 0.0,
			"max": 1.0,
			"default": 0.4,
			"hint": "Edge darkening that gently closes in on the centre.",
		},
	]
	sub_bindings = {
		"haze": [{"layer": 0, "uniform": "radius", "weight": 1.0}],
		"warmth": [{"layer": 1, "uniform": "saturation", "weight": 1.0}],
		"fade": [{"layer": 2, "uniform": "strength", "weight": 1.0}],
	}
