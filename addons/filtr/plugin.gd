@tool
extends EditorPlugin

const _FiltrDockScript := preload("res://addons/filtr/ui/filtr_dock.gd")
const _FILTR_MANAGER_AUTOLOAD := "FiltrManager"
const _FILTR_MANAGER_SCRIPT := "res://addons/filtr/core/filtr_manager.gd"

var _inspector_plugin: EditorInspectorPlugin
## UI root (Filtr panel content), parented under EditorDock.
var _dock: Control
var _editor_dock: Node
var _editor_selection: EditorSelection
var _filtr_dock_registered: bool = false
var _use_editor_dock: bool = true
## True while this plugin instance is set up (guards double _enter_tree in edge cases).
var _filtr_setup_complete: bool = false
## EditorDock.DockSlot / EditorPlugin dock slot: right column, upper area (same strip as Inspector).
const _FILTR_DOCK_SLOT := 4


func _register_filtr_project_settings() -> void:
	const QUIET_KEY := "filtr/quiet_log"
	if not ProjectSettings.has_setting(QUIET_KEY):
		ProjectSettings.set_setting(QUIET_KEY, false)
	ProjectSettings.set_initial_value(QUIET_KEY, false)
	ProjectSettings.add_property_info({"name": QUIET_KEY, "type": TYPE_BOOL})


## Godot calls this when the plugin node enters the editor tree — including on cold project open.
## Official docs register docks here, not in _enable_plugin (which may not run when a plugin was already on).
func _enter_tree() -> void:
	if _filtr_setup_complete:
		return
	_register_filtr_project_settings()
	var node_icon: Texture2D = load("res://addons/filtr/icons/filtr_node.svg") as Texture2D
	var zone_icon: Texture2D = load("res://addons/filtr/icons/filtr_zone.svg") as Texture2D
	add_custom_type(
		"FiltrNode",
		"Node",
		preload("res://addons/filtr/nodes/filtr_node.gd"),
		node_icon
	)
	add_custom_type(
		"FiltrZone",
		"Area3D",
		preload("res://addons/filtr/nodes/filtr_zone.gd"),
		zone_icon
	)
	add_custom_type(
		"FiltrZone2D",
		"Area2D",
		preload("res://addons/filtr/nodes/filtr_zone_2d.gd"),
		zone_icon
	)
	_inspector_plugin = preload("res://addons/filtr/ui/filtr_inspector_plugin.gd").new()
	_inspector_plugin.editor_setup(self)
	add_inspector_plugin(_inspector_plugin)
	_dock = _FiltrDockScript.new() as Control
	if _dock == null:
		push_error("Filtr: could not create dock panel.")
	else:
		_dock.name = "FiltrContent"
		_dock.setup(self)
		_dock.set_anchors_preset(Control.PRESET_FULL_RECT)
		_dock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_dock.size_flags_vertical = Control.SIZE_EXPAND_FILL
		# EditorDock + add_dock/remove_dock exist from Godot 4.6; 4.5 must use add_control_to_dock only.
		_use_editor_dock = ClassDB.class_exists(&"EditorDock") and has_method(&"add_dock")
		if _use_editor_dock:
			_editor_dock = ClassDB.instantiate(&"EditorDock")
			_editor_dock.set(&"title", FiltrStrings.DOCK_TAB_TITLE)
			_editor_dock.set(&"dock_icon", node_icon)
			_editor_dock.set(&"default_slot", _FILTR_DOCK_SLOT)
			_editor_dock.set(&"layout_key", "filtr_dock")
			_editor_dock.add_child(_dock)
			call("add_dock", _editor_dock)
			_filtr_dock_registered = true
		else:
			add_control_to_dock(_FILTR_DOCK_SLOT, _dock)
			_filtr_dock_registered = true
	_editor_selection = get_editor_interface().get_selection()
	if _editor_selection != null:
		_editor_selection.selection_changed.connect(_filtr_on_editor_selection_changed)
	_filtr_setup_complete = true


func _exit_tree() -> void:
	if not _filtr_setup_complete:
		return
	_filtr_setup_complete = false
	if _editor_selection != null and _editor_selection.selection_changed.is_connected(_filtr_on_editor_selection_changed):
		_editor_selection.selection_changed.disconnect(_filtr_on_editor_selection_changed)
	_editor_selection = null
	if _use_editor_dock:
		if _filtr_dock_registered and is_instance_valid(_editor_dock) and has_method(&"remove_dock"):
			call("remove_dock", _editor_dock)
			_filtr_dock_registered = false
		if is_instance_valid(_editor_dock):
			_editor_dock.queue_free()
		_editor_dock = null
	else:
		if is_instance_valid(_dock):
			remove_control_from_docks(_dock)
			_dock.queue_free()
		_filtr_dock_registered = false
	_dock = null
	remove_custom_type("FiltrZone2D")
	remove_custom_type("FiltrZone")
	remove_custom_type("FiltrNode")
	if _inspector_plugin:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null


## First-time enable from Project Settings only; tree hook does the real work.
func _enable_plugin() -> void:
	_register_filtr_project_settings()
	_ensure_filtr_manager_autoload()


func _disable_plugin() -> void:
	_remove_filtr_manager_autoload_if_ours()


func _ensure_filtr_manager_autoload() -> void:
	var k := "autoload/%s" % _FILTR_MANAGER_AUTOLOAD
	if ProjectSettings.has_setting(k):
		return
	add_autoload_singleton(_FILTR_MANAGER_AUTOLOAD, _FILTR_MANAGER_SCRIPT)


func _remove_filtr_manager_autoload_if_ours() -> void:
	var k := "autoload/%s" % _FILTR_MANAGER_AUTOLOAD
	if not ProjectSettings.has_setting(k):
		return
	var v := str(ProjectSettings.get_setting(k))
	var path_part := v.trim_prefix("*").strip_edges()
	if path_part == _FILTR_MANAGER_SCRIPT:
		remove_autoload_singleton(_FILTR_MANAGER_AUTOLOAD)


func _filtr_on_editor_selection_changed() -> void:
	if is_instance_valid(_dock):
		_dock.refresh_hint()
