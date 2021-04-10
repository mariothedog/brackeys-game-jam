class_name Bullet
extends RayCast2D

signal stopped_moving

const MOVEMENT_WEIGHT := 0.3
var MOVEMENT_RATE := MOVEMENT_WEIGHT * Constants.PHYSICS_FPS
const AT_TARGET_THRESHOLD := 0.1

var friendly_turrets := []  # Turrets the bullet won't hurt
var velocity: Vector2

var _target_pos: Vector2
var _is_moving := false

onready var sprite: Sprite = $Sprite


func _physics_process(delta: float) -> void:
	if _is_moving:
		if Util.is_vec2_equal_with_threshold(
			sprite.global_position, _target_pos, AT_TARGET_THRESHOLD
		):
			_is_moving = false
			cast_to = Vector2.ZERO
			global_position = _target_pos
			sprite.position = Vector2.ZERO
			emit_signal("stopped_moving")
			return
		var weight := min(MOVEMENT_RATE * delta * Global.step_speed, 1)
		sprite.global_position = sprite.global_position.linear_interpolate(_target_pos, weight)
	cast_to = sprite.global_position - global_position
	if is_queued_for_deletion():
		return
	force_raycast_update()
	var collider := get_collider()
	if not collider or collider in friendly_turrets or collider.is_queued_for_deletion():
		return
	explode()
	if collider is Area2D:
# warning-ignore:unsafe_method_access
		collider.explode()


func move_to(global_pos: Vector2, is_instant := false) -> void:
	_target_pos = global_pos
	if is_instant:
		global_position = _target_pos
		sprite.position = Vector2.ZERO
		return
	_is_moving = true


func move(num: int) -> void:
	move_to(_target_pos + velocity * num)


func explode() -> void:
	if is_queued_for_deletion():
		return
	emit_signal("stopped_moving")
	queue_free()
