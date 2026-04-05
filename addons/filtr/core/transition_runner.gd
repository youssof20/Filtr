class_name FiltrTransitionRunner
extends RefCounted

## Runs tweens that drive shader uniforms via Callable (prefer tween_method over tween_property on ShaderMaterial).


var _host: Node


func _init(host: Node) -> void:
	_host = host


## Fades a float value over time, calling on_step each tick with the current value.
func tween_float(duration: float, from: float, to: float, on_step: Callable) -> Tween:
	if duration <= 0.0:
		on_step.call(to)
		return null
	var tree: SceneTree = _host.get_tree()
	if tree == null:
		on_step.call(to)
		return null
	var tween: Tween = tree.create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(on_step, from, to, duration)
	return tween
