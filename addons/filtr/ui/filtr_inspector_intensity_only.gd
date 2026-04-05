@tool
extends EditorProperty

var _value_label: Label
var _slider: HSlider


func _init() -> void:
	var row := HBoxContainer.new()
	add_child(row)
	_value_label = Label.new()
	_value_label.custom_minimum_size = Vector2(44, 0)
	_value_label.text = "100%"
	row.add_child(_value_label)
	_slider = HSlider.new()
	_slider.min_value = 0.0
	_slider.max_value = 100.0
	_slider.step = 0.1
	_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_slider)
	_slider.value_changed.connect(_on_intensity_changed)


func _update_property() -> void:
	var node := get_edited_object() as FiltrNode
	if node == null:
		return
	_slider.set_block_signals(true)
	_slider.value = node.intensity
	_slider.set_block_signals(false)
	_value_label.text = "%d%%" % int(round(node.intensity))


func _on_intensity_changed(value: float) -> void:
	_value_label.text = "%d%%" % int(round(value))
	emit_changed(&"intensity", value, "", true)
