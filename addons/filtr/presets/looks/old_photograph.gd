extends FiltrLookPreset


func _init() -> void:
	display_name = "Old Photograph"
	description = "Faded sepia paper — warm brown cast, creased grain, soft focus, and burned edges."
	effects = [
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/color_grade.gdshader",
			{"saturation": -0.32, "contrast": 0.08, "rgb_tint": Vector3(1.06, 0.96, 0.86)},
			{"saturation": 0.0, "contrast": 0.0, "rgb_tint": Vector3(1.0, 1.0, 1.0)}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/grain.gdshader",
			{"amount": 0.11},
			{"amount": 0.0}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/vignette.gdshader",
			{"strength": 0.42, "radius": 0.78},
			{"strength": 0.0, "radius": 0.78}
		),
		FiltrEffectLayer.new(
			"res://addons/filtr/shaders/blur.gdshader",
			{"radius": 0.28},
			{"radius": 0.0}
		),
	]
	sub_controls = [
		{
			"key": "damage",
			"label": "Damage",
			"min": 0.0,
			"max": 1.0,
			"default": 0.5,
			"hint": "Creases, dust, and rough texture baked into the emulsion.",
		},
		{
			"key": "fade",
			"label": "Fade",
			"min": 0.0,
			"max": 1.0,
			"default": 0.45,
			"hint": "How washed and sun-faded the colours feel — lower keeps more punch.",
		},
	]
	sub_bindings = {
		"damage": [{"layer": 1, "uniform": "amount", "weight": 1.0}],
		"fade": [{"layer": 0, "uniform": "saturation", "weight": 1.0}],
	}
