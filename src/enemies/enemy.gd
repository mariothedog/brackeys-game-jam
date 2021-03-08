class_name Enemy
extends Area2D

const MOVEMENT_WEIGHT = 0.4
var MOVEMENT_RATE := MOVEMENT_WEIGHT * Constants.PHYSICS_FPS

var path: PoolVector2Array setget _set_path
var can_be_shot := true

var _path_length: int
var _path_current_index := 0
var _target_pos: Vector2


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if Util.is_equal_approx_vec2(global_position, _target_pos):
		set_physics_process(false)
		if _path_current_index + 1 == _path_length:
			queue_free()
		else:
			position = position.round()
		return
	global_position = global_position.linear_interpolate(_target_pos, MOVEMENT_RATE * delta)


func update_position_along_path() -> void:
	if _path_current_index + 1 == _path_length:
		return
	_path_current_index += 1
	_target_pos = path[_path_current_index]
	set_physics_process(true)


func explode() -> void:
	if is_queued_for_deletion():
		return
	queue_free()


func _set_path(value: PoolVector2Array) -> void:
	path = value
	_path_length = len(path)
	global_position = path[0]
