class_name Enemy
extends Area2D

signal reached_target_pos
signal reached_end_of_path
signal exploded

const NUM_TILES_TO_MOVE_PER_TURN := 2
const MOVEMENT_WEIGHT := 0.4
var MOVEMENT_RATE := MOVEMENT_WEIGHT * Constants.PHYSICS_FPS
const DAMAGE := 1

var path: PoolVector2Array setget _set_path

var _path_length: int
var _path_current_index := 0
var _target_pos: Vector2

onready var sprite: Sprite = $Sprite


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if sprite.global_position.is_equal_approx(_target_pos):
		set_physics_process(false)
		if _path_current_index + 1 == _path_length:
			emit_signal("reached_end_of_path")
		else:
			sprite.position = Vector2.ZERO
		emit_signal("reached_target_pos")
		return
	sprite.global_position = sprite.global_position.linear_interpolate(
		_target_pos, MOVEMENT_RATE * delta
	)


func update_position_along_path() -> void:
	for _i in NUM_TILES_TO_MOVE_PER_TURN:
		if _path_current_index + 1 == _path_length:
			return
		_path_current_index += 1
		_target_pos = path[_path_current_index]
		var prev_global_pos := global_position
		global_position = _target_pos
		sprite.global_position = prev_global_pos
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
