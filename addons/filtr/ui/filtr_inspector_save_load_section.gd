@tool
extends VBoxContainer

var _plugin: EditorPlugin
var _node: FiltrNode
var _name_edit: LineEdit
var _save_dlg: EditorFileDialog
var _load_dlg: EditorFileDialog


func setup(plugin: EditorPlugin, node: FiltrNode) -> void:
	_plugin = plugin
	_node = node
	custom_minimum_size = Vector2(0, 8)
	add_theme_constant_override(&"separation", 6)
	var lab := Label.new()
	lab.text = "Save / load look"
	add_child(lab)
	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "My look name"
	add_child(_name_edit)
	var row := HBoxContainer.new()
	var save_btn := Button.new()
	save_btn.text = "Save…"
	save_btn.pressed.connect(_on_save_pressed)
	row.add_child(save_btn)
	var load_btn := Button.new()
	load_btn.text = "Load…"
	load_btn.pressed.connect(_on_load_pressed)
	row.add_child(load_btn)
	add_child(row)
	var base: Control = _plugin.get_editor_interface().get_base_control()
	_save_dlg = EditorFileDialog.new()
	_save_dlg.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	_save_dlg.access = EditorFileDialog.ACCESS_RESOURCES
	_save_dlg.add_filter("*.tres", "Filtr look")
	_save_dlg.file_selected.connect(_on_save_path_chosen)
	base.add_child(_save_dlg)
	_load_dlg = EditorFileDialog.new()
	_load_dlg.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	_load_dlg.access = EditorFileDialog.ACCESS_RESOURCES
	_load_dlg.add_filter("*.tres", "Filtr look")
	_load_dlg.file_selected.connect(_on_load_path_chosen)
	base.add_child(_load_dlg)


func _exit_tree() -> void:
	if is_instance_valid(_save_dlg) and _save_dlg.get_parent():
		_save_dlg.get_parent().remove_child(_save_dlg)
		_save_dlg.queue_free()
	if is_instance_valid(_load_dlg) and _load_dlg.get_parent():
		_load_dlg.get_parent().remove_child(_load_dlg)
		_load_dlg.queue_free()


func _on_save_pressed() -> void:
	if _plugin == null or _node == null:
		return
	_save_dlg.current_dir = "res://filtr_looks"
	_save_dlg.popup_centered_ratio(0.5)


func _on_load_pressed() -> void:
	if _plugin == null or _node == null:
		return
	_load_dlg.current_dir = "res://filtr_looks"
	_load_dlg.popup_centered_ratio(0.5)


func _on_save_path_chosen(path: String) -> void:
	if _node == null:
		return
	var label := _name_edit.text.strip_edges()
	if label.is_empty():
		label = path.get_file().get_basename()
	var sl := FiltrSavedLook.capture_from_node(_node, label)
	var err := ResourceSaver.save(sl, path)
	if err != OK:
		FiltrLog.event("save look failed err=%s path=%s" % [str(err), path])
		return
	FiltrLog.event("saved look %s" % path)
	_plugin.get_editor_interface().get_resource_filesystem().scan()


func _on_load_path_chosen(path: String) -> void:
	if _node == null:
		return
	var res: Resource = load(path)
	if not res is FiltrSavedLook:
		FiltrLog.event("not a saved look: %s" % path)
		return
	var sl := res as FiltrSavedLook
	var ur: EditorUndoRedoManager = _plugin.get_undo_redo()
	var old_look := _node.look
	var old_i := _node.intensity
	var old_sub := _node.sub_values.duplicate(true)
	var new_look := sl.base_look_id
	var new_i := sl.intensity * 100.0
	var new_sub := sl.sub_values.duplicate(true)
	ur.create_action("Filtr load look")
	ur.add_do_property(_node, &"look", new_look)
	ur.add_do_property(_node, &"intensity", new_i)
	ur.add_do_property(_node, &"sub_values", new_sub)
	ur.add_undo_property(_node, &"look", old_look)
	ur.add_undo_property(_node, &"intensity", old_i)
	ur.add_undo_property(_node, &"sub_values", old_sub)
	ur.commit_action()
