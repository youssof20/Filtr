extends FiltrLookPreset


func _init() -> void:
	display_name = "High Contrast"
	description = "Graphic punch — snapped mids, boosted saturation, subtle edge darkening. Great for stylised action."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": 0.14, "contrast": 0.38, "rgb_tint": Vector3(1.0, 1.0, 1.0)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.18, "radius": 0.92},
			{"strength": 0.0, "radius": 0.92}
		),
	]
	sub_controls = [
		{
			"key": "punch",
			"label": "Punch",
			"min": 0.0,
			"max": 1.0,
			"default": 0.55,
			"hint": "Mid-tone snap — more contrast and harder separation between light and dark.",
		},
		{
			"key": "rim",
			"label": "Rim",
			"min": 0.0,
			"max": 1.0,
			"default": 0.45,
			"hint": "Edge darkening that frames the action like a spotlight falloff.",
		},
	]
	sub_bindings = {
		"punch": [{"layer": 0, "uniform": "contrast", "weight": 1.0}],
		"rim": [{"layer": 1, "uniform": "strength", "weight": 1.0}],
	}
