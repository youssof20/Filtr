@tool
extends EditorInspectorPlugin

const _PresetProp := preload("res://addons/filtr/ui/filtr_inspector_preset_prop.gd")
const _IntensityOnly := preload("res://addons/filtr/ui/filtr_inspector_intensity_only.gd")
const _SubSlidersSection := preload("res://addons/filtr/ui/filtr_inspector_sub_sliders_section.gd")
const _SaveLoadSection := preload("res://addons/filtr/ui/filtr_inspector_save_load_section.gd")

var _editor_plugin: EditorPlugin


func editor_setup(plugin: EditorPlugin) -> void:
	_editor_plugin = plugin


func _can_handle(object: Object) -> bool:
	return object is FiltrNode or object is FiltrZone or object is FiltrZone2D


func _parse_property(
	object: Object,
	_type: Variant.Type,
	name: String,
	_hint_type: PropertyHint,
	_hint_string: String,
	_usage_flags: PropertyUsageFlags,
	_wide: bool
) -> bool:
	if name == "look" and (object is FiltrNode or object is FiltrZone or object is FiltrZone2D):
		add_property_editor(name, _PresetProp.new())
		return true
	if name == "intensity" and object is FiltrNode:
		add_property_editor(name, _IntensityOnly.new())
		var subs: Control = _SubSlidersSection.new()
		subs.setup(self, object as FiltrNode)
		add_custom_control(subs)
		return true
	return false


func _parse_end(object: Object) -> void:
	if object is FiltrNode and _editor_plugin != null:
		var sec: Control = _SaveLoadSection.new()
		sec.setup(_editor_plugin, object as FiltrNode)
		add_custom_control(sec)
