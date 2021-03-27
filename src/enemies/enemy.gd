class_name Enemy
extends Area2D

signal reached_end_of_path
signal exploded

const MOVEMENT_WEIGHT := 0.3
var MOVEMENT_RATE := MOVEMENT_WEIGHT * Constants.PHYSICS_FPS
const ENEMY_AT_TARGET_THRESHOLD := 0.1
const DAMAGE := 1

var path: PoolVector2Array setget _set_path

var _path_length: int
var _path_current_index := 0
var _target_pos: Vector2

onready var sprite: Sprite = $Sprite


func _ready() -> void:
	print("New enemy: ", self)
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if Util.is_vec2_equal_with_threshold(sprite.global_position, _target_pos, ENEMY_AT_TARGET_THRESHOLD):
		set_physics_process(false)
		sprite.position = Vector2.ZERO
		if _path_current_index + 1 == _path_length:
			emit_signal("reached_end_of_path")
		return
	sprite.global_position = sprite.global_position.linear_interpolate(_target_pos, MOVEMENT_RATE * delta)


func update_position_along_path() -> void:
	if _path_current_index + 1 == _path_length:
		return
	_path_current_index += 1
	_target_pos = path[_path_current_index]
	var prev_global_pos := global_position
	global_position = _target_pos
	sprite.global_position = prev_global_pos
	set_physics_process(true)


func explode() -> void:
	if is_queued_for_deletion():
		return
	queue_free()
	emit_signal("exploded")


func _set_path(value: PoolVector2Array) -> void:
	path = value
	_path_length = len(path)
	global_position = path[0]
