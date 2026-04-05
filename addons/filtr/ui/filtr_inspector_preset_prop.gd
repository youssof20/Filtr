@tool
extends EditorProperty

var _options: OptionButton


func _init() -> void:
	_options = OptionButton.new()
	add_child(_options)
	_options.item_selected.connect(_on_item_selected)


func _ready() -> void:
	_refill_presets()


func _refill_presets() -> void:
	_options.set_block_signals(true)
	_options.clear()
	_options.add_item(FiltrStrings.INSPECTOR_NONE)
	_options.set_item_metadata(0, "")
	for preset_id in FiltrPresetRegistry.get_all_preset_ids():
		var preset: FiltrLookPreset = FiltrPresetRegistry.instantiate_preset(preset_id)
		var item_label: String = preset_id
		if preset:
			item_label = preset.display_name
		_options.add_item(item_label)
		_options.set_item_metadata(_options.item_count - 1, preset_id)
	_options.set_block_signals(false)


func _look_from_object(obj: Object) -> String:
	if obj is FiltrNode:
		return (obj as FiltrNode).look
	if obj is FiltrZone:
		return (obj as FiltrZone).look
	if obj is FiltrZone2D:
		return (obj as FiltrZone2D).look
	return ""


func _update_property() -> void:
	if _options.item_count == 0:
		_refill_presets()
	var obj := get_edited_object()
	if obj == null:
		return
	_options.set_block_signals(true)
	var current: String = _look_from_object(obj)
	var found := false
	for i in _options.item_count:
		if str(_options.get_item_metadata(i)) == current:
			_options.select(i)
			found = true
			break
	if not found:
		_options.select(0)
	_options.set_block_signals(false)


func _on_item_selected(index: int) -> void:
	var meta: Variant = _options.get_item_metadata(index)
	emit_changed(get_edited_property(), str(meta), "", true)
