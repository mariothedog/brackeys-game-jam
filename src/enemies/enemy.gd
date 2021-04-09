class_name Enemy
extends Area2D

signal stopped_moving
signal reached_end_of_path
signal exploded

const MOVEMENT_WEIGHT := 0.3
var MOVEMENT_RATE := MOVEMENT_WEIGHT * Constants.PHYSICS_FPS
const AT_TARGET_THRESHOLD := 0.1
const DAMAGE := 1

var path: Array setget _set_path

var _path_length: int
var _path_current_index := 0
var _target_pos: Vector2
var _target_points: PoolVector2Array


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if Util.is_vec2_equal_with_threshold(global_position, _target_pos, AT_TARGET_THRESHOLD):
		set_physics_process(false)
		global_position = _target_pos
		emit_signal("stopped_moving")
		if _path_current_index + 1 == _path_length:
			emit_signal("reached_end_of_path")
		return
	var weight := min(MOVEMENT_RATE * delta * Global.step_speed, 1)
	var new_pos_and_points = Util.lerp_through_points(
		global_position, _target_pos, _target_points, weight
	)
	global_position = new_pos_and_points[0]
	_target_points = new_pos_and_points[1]


func lerp_vec(a: Vector2, b: Vector2, w: float):
	a.x += w * (b.x - a.x)
	a.y += w * (b.y - a.y)
	return a


func update_position_along_path(num: int) -> void:
	var old_path_index := _path_current_index
	if _path_current_index + 1 == _path_length:
		return
	elif _path_current_index + num >= _path_length:
		_path_current_index = _path_length - 1
	else:
		_path_current_index += num
	_target_pos = path[_path_current_index]
	_target_points = path.slice(old_path_index + 1, _path_current_index)
	set_physics_process(true)


func explode() -> void:
	if is_queued_for_deletion():
		return
	emit_signal("stopped_moving")
	emit_signal("exploded")
	queue_free()


func _set_path(value: Array) -> void:
	path = value
	_path_length = len(path)
	global_position = path[0]
