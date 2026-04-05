class_name FiltrEffectLayer
extends Resource

@export var shader_path: String = ""
@export var base_params: Dictionary = {}
@export var zero_params: Dictionary = {}


func _init(
	p_shader_path: String = "",
	p_base_params: Dictionary = {},
	p_zero_params: Dictionary = {}
) -> void:
	shader_path = p_shader_path
	base_params = p_base_params
	zero_params = p_zero_params
