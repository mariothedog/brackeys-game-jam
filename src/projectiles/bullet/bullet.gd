class_name Bullet
extends Area2D

const MOVEMENT_WEIGHT := 0.3
var MOVEMENT_RATE := MOVEMENT_WEIGHT * Constants.PHYSICS_FPS

var friendly_turrets := []  # Turrets the bullet won't hurt
var parent_pos: Vector2
var dir: Vector2

var _target_pos: Vector2
var _num_movements := 1


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if global_position.is_equal_approx(_target_pos):
		set_physics_process(false)
		global_position = _target_pos
		return
	global_position = global_position.linear_interpolate(
		_target_pos, MOVEMENT_RATE * delta
	)


func move(amount: Vector2) -> void:
	_target_pos = parent_pos + dir * amount * _num_movements
	_num_movements += 1
	set_physics_process(true)


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
