class_name FiltrLookPreset
extends Resource

@export var display_name: String = ""
@export var description: String = ""
@export var effects: Array[FiltrEffectLayer] = []
## Each entry: key, label, min, max, default, hint (plain English for tooltips).
var sub_controls: Array = []
## Maps control key -> Array of binding dicts: layer, uniform, weight (scale mode) OR direct, direct_min, direct_max.
var sub_bindings: Dictionary = {}
