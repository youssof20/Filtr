extends FiltrLookPreset


func _init() -> void:
	display_name = "Warm Cinema"
	description = "Theatre warmth — amber lift, gentle edge darkening, soft halation, and fine grain."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": 0.04, "contrast": -0.04, "rgb_tint": Vector3(1.06, 0.97, 0.88)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.36, "radius": 0.82},
			{"strength": 0.0, "radius": 0.82}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/blur.gdshader",
			{"radius": 0.4},
			{"radius": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/grain.gdshader",
			{"amount": 0.038},
			{"amount": 0.0}
		),
	]
	sub_controls = [
		{
			"key": "haze",
			"label": "Haze",
			"min": 0.0,
			"max": 1.0,
			"default": 0.45,
			"hint": "Soft halation around bright areas — like projector bloom in a smoky room.",
		},
		{
			"key": "grain",
			"label": "Grain",
			"min": 0.0,
			"max": 1.0,
			"default": 0.4,
			"hint": "Fine film texture that keeps the image from feeling too digital.",
		},
	]
	sub_bindings = {
		"haze": [{"layer": 2, "uniform": "radius", "weight": 1.0}],
		"grain": [{"layer": 3, "uniform": "amount", "weight": 1.0}],
	}
