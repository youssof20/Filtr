extends FiltrLookPreset


func _init() -> void:
	display_name = "Soft Focus"
	description = "Romantic portrait vibe: gentle blur, softened contrast, and a light vignette."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/blur.gdshader",
			{"radius": 1.55},
			{"radius": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": -0.28, "contrast": -0.06, "rgb_tint": Vector3(1.03, 1.0, 1.05)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.5, "radius": 0.92},
			{"strength": 0.0, "radius": 0.92}
		),
	]
	sub_controls = [
		{
			"key": "dream",
			"label": "Dream",
			"min": 0.0,
			"max": 1.0,
			"default": 0.55,
			"hint": "How soft and out-of-focus the image feels.",
		},
		{
			"key": "mood",
			"label": "Mood",
			"min": 0.0,
			"max": 1.0,
			"default": 0.45,
			"hint": "Desaturation and flattening — wistful, memory-like.",
		},
		{
			"key": "frame",
			"label": "Frame",
			"min": 0.0,
			"max": 1.0,
			"default": 0.5,
			"hint": "Darkening toward the edges to keep eyes in the centre.",
		},
	]
	sub_bindings = {
		"dream": [{"layer": 0, "uniform": "radius", "weight": 1.0}],
		"mood": [{"layer": 1, "uniform": "saturation", "weight": 1.0}],
		"frame": [{"layer": 2, "uniform": "strength", "weight": 1.0}],
	}
