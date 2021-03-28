class_name Bullet
extends Area2D

const MOVEMENT_WEIGHT := 0.3
var MOVEMENT_RATE := MOVEMENT_WEIGHT * Constants.PHYSICS_FPS
const AT_TARGET_THRESHOLD := 0.1

var friendly_turrets := []  # Turrets the bullet won't hurt
var velocity: Vector2

var _target_pos: Vector2


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if Util.is_vec2_equal_with_threshold(global_position, _target_pos, AT_TARGET_THRESHOLD):
		set_physics_process(false)
		global_position = _target_pos
		return
	global_position = global_position.linear_interpolate(_target_pos, MOVEMENT_RATE * delta)


func move_to(global_pos: Vector2) -> void:
	_target_pos = global_pos
	set_physics_process(true)


func move() -> void:
	move_to(global_position + velocity)


func explode() -> void:
	if is_queued_for_deletion():
		return
	queue_free()


func _on_Bullet_area_entered(area: Area2D) -> void:
	if is_queued_for_deletion() or area in friendly_turrets:
		return
	explode()
# warning-ignore:unsafe_method_access
	area.explode()


func _on_Bullet_body_entered(_body: TileMap) -> void:
	if is_queued_for_deletion():
		return
	explode()
