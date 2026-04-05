@tool
extends Control

const _THUMB_DIR := "res://addons/filtr/thumbnails"

var _plugin: EditorPlugin
var _builtin_rows: Array[Dictionary] = []
var _saved_paths: PackedStringArray = PackedStringArray()
var _visible_rows: Array[Dictionary] = []
var _search: LineEdit
var _subtitle: Label
var _list: ItemList
var _hint: Label
var _thumb_popup: PopupPanel
var _thumb_rect: TextureRect
var _thumb_tex: ImageTexture
var _hover_index: int = -1


func setup(plugin: EditorPlugin) -> void:
	_plugin = plugin


func _ready() -> void:
	custom_minimum_size = Vector2(420, 260)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)
	var v := VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	margin.add_child(v)
	var title := Label.new()
	title.text = FiltrStrings.DOCK_HEADER
	v.add_child(title)
	_subtitle = Label.new()
	_subtitle.add_theme_color_override(&"font_color", Color(0.65, 0.65, 0.68, 1.0))
	v.add_child(_subtitle)
	_search = LineEdit.new()
	_search.placeholder_text = FiltrStrings.DOCK_SEARCH_PLACEHOLDER
	_search.clear_button_enabled = true
	_search.text_changed.connect(_on_search_changed)
	_search.gui_input.connect(_on_search_gui_input)
	v.add_child(_search)
	var sep := HSeparator.new()
	v.add_child(sep)
	_list = ItemList.new()
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.custom_minimum_size = Vector2(0, 200)
	_list.allow_reselect = true
	_list.item_selected.connect(_on_list_item_selected)
	_list.gui_input.connect(_on_list_gui_input)
	_list.mouse_exited.connect(_on_list_mouse_exited)
	v.add_child(_list)
	_hint = Label.new()
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.text = FiltrStrings.DOCK_HINT_NONE
	v.add_child(_hint)
	_thumb_popup = PopupPanel.new()
	_thumb_popup.visible = false
	_thumb_rect = TextureRect.new()
	_thumb_rect.custom_minimum_size = Vector2(160, 90)
	_thumb_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_thumb_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_thumb_popup.add_child(_thumb_rect)
	var base := _plugin.get_editor_interface().get_base_control()
	base.add_child(_thumb_popup)
	_rebuild_builtin_cache()
	_scan_saved_looks()
	_refresh_list_from_filter()
	refresh_hint()


func _exit_tree() -> void:
	if is_instance_valid(_thumb_popup) and _thumb_popup.get_parent():
		_thumb_popup.get_parent().remove_child(_thumb_popup)
		_thumb_popup.queue_free()


func refresh_hint() -> void:
	if _hint == null:
		return
	var n := _find_selected_filtr_node()
	_hint.text = FiltrStrings.DOCK_HINT_SELECTED if n != null else FiltrStrings.DOCK_HINT_NONE
	sync_list_to_filtr_node()


func sync_list_to_filtr_node() -> void:
	if _list == null:
		return
	_list.set_block_signals(true)
	var node := _find_selected_filtr_node()
	if node == null:
		_list.deselect_all()
		_list.set_block_signals(false)
		return
	var cur: String = node.look
	var found := false
	for i in _list.item_count:
		var md: Variant = _list.get_item_metadata(i)
		if md is Dictionary:
			var d: Dictionary = md
			if str(d.get("kind", "")) == "builtin" and str(d.get("id", "")) == cur:
				_list.select(i)
				_list.ensure_current_is_visible()
				found = true
				break
	if not found:
		_list.deselect_all()
	_list.set_block_signals(false)


func _update_subtitle() -> void:
	if _subtitle == null or _list == null:
		return
	var q := _search.text.strip_edges()
	var total: int = _builtin_rows.size() + _saved_paths.size()
	var vis: int = _list.item_count
	if not q.is_empty() and vis == 0:
		_subtitle.text = FiltrStrings.DOCK_NO_MATCH % q
	elif total == 0:
		_subtitle.text = "No looks loaded"
	elif q.is_empty() or vis >= total:
		_subtitle.text = "%d looks" % total
	else:
		_subtitle.text = "Showing %d of %d" % [vis, total]


func _rebuild_builtin_cache() -> void:
	_builtin_rows.clear()
	for preset_id in FiltrPresetRegistry.get_all_preset_ids():
		var preset: FiltrLookPreset = FiltrPresetRegistry.instantiate_preset(preset_id)
		if preset == null:
			continue
		_builtin_rows.append(
			{
				"id": preset_id,
				"name": preset.display_name,
				"desc": preset.description,
			}
		)
	_builtin_rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a["name"]) < str(b["name"]))


func _scan_saved_looks() -> void:
	_saved_paths = PackedStringArray()
	var dir := DirAccess.open(FiltrStrings.SAVED_LOOKS_DIR)
	if dir == null:
		return
	dir.list_dir_begin()
	var fn := dir.get_next()
	while fn != "":
		if not dir.current_is_dir() and fn.ends_with(".tres"):
			_saved_paths.append("%s/%s" % [FiltrStrings.SAVED_LOOKS_DIR, fn])
		fn = dir.get_next()
	dir.list_dir_end()
	_saved_paths.sort()


func _subsequence_match(q: String, text: String) -> bool:
	if q.is_empty():
		return true
	var qi := 0
	var ql := q.length()
	for i in text.length():
		if qi < ql and text[i] == q[qi]:
			qi += 1
	return qi == ql


func _row_matches_query(q: String, name: String, id: String) -> bool:
	if q.is_empty():
		return true
	var ql := q.to_lower()
	return _subsequence_match(ql, name.to_lower()) or _subsequence_match(ql, id.to_lower())


func _on_search_changed(_t: String) -> void:
	_refresh_list_from_filter()


func _on_search_gui_input(ev: InputEvent) -> void:
	if ev is InputEventKey and ev.pressed and ev.keycode == KEY_ESCAPE:
		_search.text = ""
		_refresh_list_from_filter()
		accept_event()


func _refresh_list_from_filter() -> void:
	if _list == null:
		return
	_list.set_block_signals(true)
	_list.clear()
	_visible_rows.clear()
	var q := _search.text.strip_edges().to_lower()
	for row in _builtin_rows:
		var nm := str(row["name"])
		var id := str(row["id"])
		if _row_matches_query(q, nm, id):
			var ix := _list.add_item(nm)
			var md := {"kind": "builtin", "id": id, "name": nm, "desc": str(row["desc"])}
			_list.set_item_metadata(ix, md)
			_list.set_item_tooltip(ix, str(row["desc"]))
			_visible_rows.append(md)
	for path in _saved_paths:
		var res: Resource = load(path)
		var label := path.get_file().get_basename()
		if res is FiltrSavedLook:
			label = (res as FiltrSavedLook).display_label
			if (res as FiltrSavedLook).display_label.strip_edges().is_empty():
				label = path.get_file().get_basename()
		var slug := path.get_file().get_basename()
		if _row_matches_query(q, label, slug):
			var ix2 := _list.add_item(label)
			var md2 := {"kind": "saved", "path": path, "name": label}
			_list.set_item_metadata(ix2, md2)
			_list.set_item_tooltip(ix2, path)
			_visible_rows.append(md2)
	_list.set_block_signals(false)
	_update_subtitle()
	sync_list_to_filtr_node()


func _find_selected_filtr_node() -> FiltrNode:
	if _plugin == null:
		return null
	var sel := _plugin.get_editor_interface().get_selection().get_selected_nodes()
	for node in sel:
		if node is FiltrNode:
			return node as FiltrNode
	return null


func _on_list_item_selected(index: int) -> void:
	_apply_row_at_index(index)


func _on_list_gui_input(ev: InputEvent) -> void:
	if ev is InputEventMouseMotion:
		var idx := _list.get_item_at_position(ev.position)
		if idx != _hover_index:
			_hover_index = idx
			if idx < 0:
				_thumb_popup.hide()
			else:
				_maybe_show_thumbnail(idx)
	elif ev is InputEventKey and ev.pressed and ev.keycode == KEY_ENTER:
		var sel := _list.get_selected_items()
		if sel.size() > 0:
			_apply_row_at_index(sel[0])
			accept_event()
	elif ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_RIGHT:
		var idx := _list.get_item_at_position(ev.position)
		if idx >= 0:
			var md: Variant = _list.get_item_metadata(idx)
			if md is Dictionary and str((md as Dictionary).get("kind", "")) == "saved":
				_confirm_delete_saved(str((md as Dictionary).get("path", "")))
				accept_event()


func _on_list_mouse_exited() -> void:
	_hover_index = -1
	_thumb_popup.hide()


func _maybe_show_thumbnail(index: int) -> void:
	var md: Variant = _list.get_item_metadata(index)
	if md is Dictionary and str((md as Dictionary).get("kind", "")) == "builtin":
		var lid := str((md as Dictionary).get("id", ""))
		var png := "%s/%s.png" % [_THUMB_DIR, lid]
		if not ResourceLoader.exists(png):
			_thumb_popup.hide()
			return
		if _thumb_tex == null:
			_thumb_tex = ImageTexture.new()
		var img := Image.load_from_file(png)
		if img == null:
			_thumb_popup.hide()
			return
		_thumb_tex.set_image(img)
		_thumb_rect.texture = _thumb_tex
		var gp := _list.get_global_mouse_position()
		_thumb_popup.position = gp + Vector2(16, 16)
		_thumb_popup.popup()
	else:
		_thumb_popup.hide()


func _confirm_delete_saved(path: String) -> void:
	if path.is_empty():
		return
	var dlg := ConfirmationDialog.new()
	dlg.dialog_text = FiltrStrings.DOCK_DELETE_CONFIRM % path.get_file()
	dlg.confirmed.connect(
		func() -> void:
			_do_delete_saved(path)
			dlg.queue_free()
	)
	_plugin.get_editor_interface().get_base_control().add_child(dlg)
	dlg.popup_centered()


func _do_delete_saved(path: String) -> void:
	var err := OK
	var dopen := DirAccess.open(FiltrStrings.SAVED_LOOKS_DIR)
	if dopen:
		err = dopen.remove(path.get_file())
	else:
		err = FAILED
	if err != OK:
		FiltrLog.event("delete saved look failed %s err=%s" % [path, str(err)])
	_scan_saved_looks()
	_refresh_list_from_filter()
	_plugin.get_editor_interface().get_resource_filesystem().scan()


func _apply_row_at_index(index: int) -> void:
	if _plugin == null or _list == null:
		return
	var target := _find_selected_filtr_node()
	if target == null:
		refresh_hint()
		return
	var md: Variant = _list.get_item_metadata(index)
	if not md is Dictionary:
		return
	var d: Dictionary = md
	var kind := str(d.get("kind", ""))
	var ur: EditorUndoRedoManager = _plugin.get_undo_redo()
	if kind == "builtin":
		var new_id: String = str(d.get("id", ""))
		var old_id: String = target.look
		if old_id == new_id:
			return
		ur.create_action(FiltrStrings.DOCK_UNDO_APPLY)
		ur.add_do_property(target, &"look", new_id)
		ur.add_undo_property(target, &"look", old_id)
		ur.commit_action()
		FiltrLog.event("dock apply look=%s" % new_id)
	elif kind == "saved":
		var path := str(d.get("path", ""))
		var res: Resource = load(path)
		if not res is FiltrSavedLook:
			return
		var sl := res as FiltrSavedLook
		var old_look := target.look
		var old_i := target.intensity
		var old_sub := target.sub_values.duplicate(true)
		var new_look := sl.base_look_id
		var new_i := sl.intensity * 100.0
		var new_sub := sl.sub_values.duplicate(true)
		ur.create_action(FiltrStrings.DOCK_UNDO_APPLY_SAVED)
		# Apply sub_values and intensity before look so inspector detail rows refresh with correct keys.
		ur.add_do_property(target, &"sub_values", new_sub)
		ur.add_do_property(target, &"intensity", new_i)
		ur.add_do_property(target, &"look", new_look)
		ur.add_undo_property(target, &"sub_values", old_sub)
		ur.add_undo_property(target, &"intensity", old_i)
		ur.add_undo_property(target, &"look", old_look)
		ur.commit_action()
		FiltrLog.event("dock apply saved look %s" % path)
