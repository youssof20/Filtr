extends FiltrLookPreset


func _init() -> void:
	display_name = "Film Noir"
	description = "High-contrast black-and-white drama with a strong vignette."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": -0.92, "contrast": 0.35, "rgb_tint": Vector3(1.0, 1.0, 1.0)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.55, "radius": 0.72},
			{"strength": 0.0, "radius": 0.72}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/grain.gdshader",
			{"amount": 0.05},
			{"amount": 0.0}
		),
	]
	sub_controls = [
		{
			"key": "crush",
			"label": "Crush",
			"min": 0.0,
			"max": 1.0,
			"default": 0.55,
			"hint": "How hard the mids snap toward black and white — more reads harsher and more graphic.",
		},
		{
			"key": "grain",
			"label": "Grain",
			"min": 0.0,
			"max": 1.0,
			"default": 0.45,
			"hint": "Fine speckle like photochemical stock in a dark theatre.",
		},
	]
	sub_bindings = {
		"crush": [{"layer": 0, "uniform": "contrast", "weight": 1.0}],
		"grain": [{"layer": 2, "uniform": "amount", "weight": 1.0}],
	}
