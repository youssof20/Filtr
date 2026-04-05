@tool
class_name FiltrZone
extends Area3D

enum OnZoneExit {
	## When the last overlapping zone releases, blend back to the FiltrNode’s own look.
	RESTORE,
	## Fade the post stack off instead of restoring the driver look.
	CLEAR,
}

var _camera_bodies_inside: int = 0

@export_group("Filtr")
@export var look: String = ""
## Fade time in seconds when entering or leaving this volume.
@export_range(0.0, 3.0, 0.05) var blend_duration: float = 0.5
@export var on_exit: OnZoneExit = OnZoneExit.RESTORE
## Higher wins when several zones overlap (not the same as the engine’s physics priority on Area3D).
@export var filtr_priority: int = 0


func _validate_property(property: Dictionary) -> void:
	if not Engine.is_editor_hint():
		return
	var n: StringName = property.get("name", &"")
	if n != &"filtr_priority":
		return
	var iface := Engine.get_singleton(&"EditorInterface")
	if iface == null:
		return
	var scene_root: Node = iface.get_edited_scene_root()
	if scene_root == null:
		return
	if _filtr_count_zones_in_scene(scene_root) <= 1:
		property["usage"] = PROPERTY_USAGE_STORAGE


func _get_configuration_warnings() -> PackedStringArray:
	if not _filtr_zone_has_collision_shape(self):
		return PackedStringArray(
			["Add a CollisionShape3D child so the volume can detect the camera."]
		)
	return PackedStringArray()


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


## Returns true when this node or any descendant is a Camera3D, or the body carries one as a direct child.
static func subtree_has_camera_3d(root: Node) -> bool:
	if root == null:
		return false
	if root.find_child("Camera3D", true, false) != null:
		return true
	if root is Camera3D:
		return true
	for c in root.get_children():
		if subtree_has_camera_3d(c):
			return true
	return false


static func _filtr_count_zones_in_scene(root: Node) -> int:
	var n := 0
	if root is FiltrZone or root is FiltrZone2D:
		n += 1
	for c in root.get_children():
		n += _filtr_count_zones_in_scene(c)
	return n


static func _filtr_zone_has_collision_shape(root: Node) -> bool:
	for c in root.get_children():
		if c is CollisionShape3D:
			return true
	return false


func _on_body_entered(body: Node) -> void:
	if not subtree_has_camera_3d(body):
		return
	_camera_bodies_inside += 1
	if _camera_bodies_inside == 1:
		FiltrManager.zone_body_entered(self)


func _on_body_exited(body: Node) -> void:
	if not subtree_has_camera_3d(body):
		return
	_camera_bodies_inside = maxi(0, _camera_bodies_inside - 1)
	if _camera_bodies_inside == 0:
		FiltrManager.zone_body_exited(self)
