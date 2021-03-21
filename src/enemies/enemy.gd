class_name Enemy
extends Area2D

signal reached_target_pos
signal reached_end_of_path
signal exploded

const MOVEMENT_WEIGHT := 0.4
var MOVEMENT_RATE := MOVEMENT_WEIGHT * Constants.PHYSICS_FPS
const DAMAGE := 1

var path: PoolVector2Array setget _set_path

var _path_length: int
var _path_current_index := 0
var _target_pos: Vector2


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if global_position.is_equal_approx(_target_pos):
		set_physics_process(false)
		if _path_current_index + 1 == _path_length:
			emit_signal("reached_end_of_path")
		else:
			global_position = _target_pos
		emit_signal("reached_target_pos")
		return
	global_position = global_position.linear_interpolate(
		_target_pos, MOVEMENT_RATE * delta
	)


func update_position_along_path() -> void:
	if _path_current_index + 1 == _path_length:
		return
	_path_current_index += 1
	_target_pos = path[_path_current_index]
	set_physics_process(true)
	yield(self, "reached_target_pos")


func explode() -> void:
	if is_queued_for_deletion():
		return
	queue_free()
	emit_signal("exploded")


func _set_path(value: PoolVector2Array) -> void:
	path = value
	_path_length = len(path)
	global_position = path[0]
