@tool
class_name FiltrZone2D
extends Area2D

enum CameraTrackMode {
	## Use Area2D body_entered / body_exited (e.g. character carrying Camera2D).
	PHYSICS_BODIES,
	## Follow the active Camera2D each physics frame (works without a physics body on the camera).
	VIEWPORT_CAMERA,
}

enum OnZoneExit {
	RESTORE,
	CLEAR,
}

var _camera_bodies_inside: int = 0
var _viewport_cam_was_inside: bool = false

@export_group("Filtr")
@export var look: String = ""
## Fade time in seconds when entering or leaving this volume.
@export_range(0.0, 3.0, 0.05) var blend_duration: float = 0.5
@export var on_exit: OnZoneExit = OnZoneExit.RESTORE
## Higher wins when several zones overlap (not the same as the engine’s physics priority on Area2D).
@export var filtr_priority: int = 0
@export var camera_track_mode: CameraTrackMode = CameraTrackMode.VIEWPORT_CAMERA


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
	if FiltrZone._filtr_count_zones_in_scene(scene_root) <= 1:
		property["usage"] = PROPERTY_USAGE_STORAGE


func _get_configuration_warnings() -> PackedStringArray:
	if not _filtr_zone_has_collision_shape(self):
		return PackedStringArray(
			["Add a CollisionShape2D child so the volume can detect the camera."]
		)
	return PackedStringArray()


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	set_physics_process(camera_track_mode == CameraTrackMode.VIEWPORT_CAMERA)


func _physics_process(_delta: float) -> void:
	if camera_track_mode != CameraTrackMode.VIEWPORT_CAMERA:
		return
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		if _viewport_cam_was_inside:
			_viewport_cam_was_inside = false
			FiltrManager.zone_body_exited(self)
		return
	var inside := _is_point_inside_area(cam.global_position)
	if inside and not _viewport_cam_was_inside:
		_viewport_cam_was_inside = true
		FiltrManager.zone_body_entered(self)
	elif not inside and _viewport_cam_was_inside:
		_viewport_cam_was_inside = false
		FiltrManager.zone_body_exited(self)


static func subtree_has_camera_2d(root: Node) -> bool:
	if root == null:
		return false
	if root.find_child("Camera2D", true, false) != null:
		return true
	if root is Camera2D:
		return true
	for c in root.get_children():
		if subtree_has_camera_2d(c):
			return true
	return false


static func _filtr_zone_has_collision_shape(root: Node) -> bool:
	for c in root.get_children():
		if c is CollisionShape2D or c is CollisionPolygon2D:
			return true
	return false


func _is_point_inside_area(global_point: Vector2) -> bool:
	var space := get_world_2d().direct_space_state
	var q := PhysicsPointQueryParameters2D.new()
	q.position = global_point
	q.collide_with_areas = true
	q.collide_with_bodies = false
	q.collision_mask = collision_layer
	var hits := space.intersect_point(q, 32)
	for h in hits:
		if h.collider == self:
			return true
	return false


func _on_body_entered(body: Node) -> void:
	if camera_track_mode != CameraTrackMode.PHYSICS_BODIES:
		return
	if not subtree_has_camera_2d(body):
		return
	_camera_bodies_inside += 1
	if _camera_bodies_inside == 1:
		FiltrManager.zone_body_entered(self)


func _on_body_exited(body: Node) -> void:
	if camera_track_mode != CameraTrackMode.PHYSICS_BODIES:
		return
	if not subtree_has_camera_2d(body):
		return
	_camera_bodies_inside = maxi(0, _camera_bodies_inside - 1)
	if _camera_bodies_inside == 0:
		FiltrManager.zone_body_exited(self)
