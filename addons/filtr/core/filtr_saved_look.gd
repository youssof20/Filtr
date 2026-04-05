## Saved Filtr configuration (built-in look id + strength + per-look detail values).
class_name FiltrSavedLook
extends Resource

@export var display_label: String = ""
## Built-in look id (e.g. `film_noir`), not a display title.
@export var base_look_id: String = ""
## 0.0 (off) .. 1.0 (full); maps to FiltrNode intensity 0–100.
@export_range(0.0, 1.0, 0.001) var intensity: float = 1.0
## Same keys as FiltrNode.sub_values (`"{look_id}:{key}"` -> value).
@export var sub_values: Dictionary = {}


static func capture_from_node(node: FiltrNode, label: String) -> FiltrSavedLook:
	var sl := FiltrSavedLook.new()
	sl.display_label = label.strip_edges()
	sl.base_look_id = node.look
	sl.intensity = clampf(node.intensity / 100.0, 0.0, 1.0)
	sl.sub_values = node.sub_values.duplicate(true)
	return sl


func apply_to_node(node: FiltrNode) -> void:
	node.look = base_look_id
	node.intensity = intensity * 100.0
	node.sub_values = sub_values.duplicate(true)
