@tool
extends MarginContainer

const _MUTED := Color(0.541, 0.541, 0.541, 1.0)
const _SEP := Color(0.212, 0.212, 0.212, 1.0)
const _SIG_FILTR_CHANGED := &"filtr_changed"

var _plugin: EditorInspectorPlugin
var _node: FiltrNode
var _vbox: VBoxContainer
var _filtr_changed_cb: Callable
## Last look id we built sliders for (avoid full rebuild on intensity-only filtr_changed).
var _last_built_look: String = ""


func setup(plugin: EditorInspectorPlugin, node: FiltrNode) -> void:
	_plugin = plugin
	_node = node
	_filtr_changed_cb = Callable(self, "_on_filtr_changed_filter_rebuild")
	add_theme_constant_override(&"margin_left", 8)
	add_theme_constant_override(&"margin_right", 8)
	add_theme_constant_override(&"margin_top", 4)
	add_theme_constant_override(&"margin_bottom", 2)
	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override(&"separation", 8)
	add_child(_vbox)
	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 1)
	sep.color = _SEP
	_vbox.add_child(sep)
	_rebuild()
	_last_built_look = _node.look if _node != null else ""
	if _node != null and _node.has_signal(_SIG_FILTR_CHANGED):
		if not _node.is_connected(_SIG_FILTR_CHANGED, _filtr_changed_cb):
			_node.connect(_SIG_FILTR_CHANGED, _filtr_changed_cb)


func _exit_tree() -> void:
	if _node != null and _node.has_signal(_SIG_FILTR_CHANGED):
		if _node.is_connected(_SIG_FILTR_CHANGED, _filtr_changed_cb):
			_node.disconnect(_SIG_FILTR_CHANGED, _filtr_changed_cb)


func _on_filtr_changed_filter_rebuild() -> void:
	if _node == null:
		return
	if _node.look == _last_built_look:
		return
	_last_built_look = _node.look
	_rebuild()


func _rebuild() -> void:
	if _vbox == null:
		return
	for i in range(_vbox.get_child_count() - 1, 0, -1):
		var c: Node = _vbox.get_child(i)
		c.queue_free()
	if _node == null:
		return
	if _node.look.is_empty():
		var tip := Label.new()
		tip.add_theme_color_override(&"font_color", Color(0.55, 0.55, 0.58, 1.0))
		tip.text = "Pick a look to tune details."
		_vbox.add_child(tip)
		return
	var preset: FiltrLookPreset = FiltrPresetRegistry.instantiate_preset(_node.look)
	if preset == null or preset.sub_controls.is_empty():
		return
	for ctrl in preset.sub_controls:
		if not ctrl is Dictionary:
			continue
		var d: Dictionary = ctrl
		var key := str(d.get("key", ""))
		if key.is_empty():
			continue
		var row := VBoxContainer.new()
		row.add_theme_constant_override(&"separation", 4)
		var lab := Label.new()
		lab.add_theme_color_override(&"font_color", _MUTED)
		lab.add_theme_font_size_override(&"font_size", 12)
		lab.text = str(d.get("label", key))
		var hint := str(d.get("hint", ""))
		if not hint.is_empty():
			lab.tooltip_text = hint
		row.add_child(lab)
		var h := HBoxContainer.new()
		var s := HSlider.new()
		var mn := float(d.get("min", 0.0))
		var mx := float(d.get("max", 1.0))
		s.min_value = mn
		s.max_value = mx
		s.step = (mx - mn) / 200.0 if mx > mn else 0.01
		s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var sk := "%s:%s" % [_node.look, key]
		var defv := float(d.get("default", mn))
		s.value = float(_node.sub_values.get(sk, defv))
		var num := Label.new()
		num.custom_minimum_size = Vector2(52, 0)
		num.text = _format_sub_value(s.value, mn, mx)
		s.value_changed.connect(
			func(v: float) -> void: _on_sub_slider_changed(key, num, mn, mx, v)
		)
		h.add_child(s)
		h.add_child(num)
		row.add_child(h)
		_vbox.add_child(row)


func _format_sub_value(v: float, mn: float, mx: float) -> String:
	if is_equal_approx(mx - mn, 1.0) or (mn >= 0.0 and mx <= 1.0 + 0.001):
		return "%d%%" % int(round(inverse_lerp(mn, mx, v) * 100.0))
	return "%.2f" % v


func _on_sub_slider_changed(key: String, num: Label, mn: float, mx: float, v: float) -> void:
	num.text = _format_sub_value(v, mn, mx)
	if _plugin == null or _node == null:
		return
	var sk := "%s:%s" % [_node.look, key]
	var old: Dictionary = _node.sub_values.duplicate(true)
	var newd: Dictionary = old.duplicate(true)
	newd[sk] = v
	var ur: EditorUndoRedoManager = _plugin.get_undo_redo()
	ur.create_action("Filtr look detail", UndoRedo.MERGE_ALL)
	ur.add_do_property(_node, &"sub_values", newd)
	ur.add_undo_property(_node, &"sub_values", old)
	ur.commit_action()
