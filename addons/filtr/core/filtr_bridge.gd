class_name FiltrBridge
extends RefCounted

## Resolves the FiltrManager autoload without naming it as a global (so scripts parse in projects that have not yet saved autoload to disk).
static func manager() -> Node:
	var tl := Engine.get_main_loop() as SceneTree
	if tl == null:
		return null
	return tl.root.get_node_or_null("FiltrManager")
