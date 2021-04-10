class_name Enemy
extends Area2D

signal stopped_moving
signal reached_end_of_path
signal exploded

const MOVEMENT_WEIGHT := 0.3
var MOVEMENT_RATE := MOVEMENT_WEIGHT * Constants.PHYSICS_FPS
const AT_TARGET_THRESHOLD := 0.1
const DAMAGE := 1

const TEMP_COLLIDER_GROUP_NAME := "temp_collider"

var path: Array setget _set_path

var _path_length: int
var _path_current_index := 0
var _target_pos: Vector2
var _target_points: PoolVector2Array

onready var tree := get_tree()
onready var sprite: Sprite = $Sprite
onready var collider: CollisionShape2D = $CollisionShape2D
onready var sight_blocker: StaticBody2D = $SightBlocker
onready var movable_children := [sprite, collider, sight_blocker]


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if Util.is_vec2_equal_with_threshold(sprite.global_position, _target_pos, AT_TARGET_THRESHOLD):
		set_physics_process(false)
		global_position = _target_pos
		for child in movable_children:
			child.position = Vector2.ZERO
		tree.call_group(TEMP_COLLIDER_GROUP_NAME, "queue_free")
		emit_signal("stopped_moving")
		if _path_current_index + 1 == _path_length:
			emit_signal("reached_end_of_path")
		return
	var weight := min(MOVEMENT_RATE * delta * Global.step_speed, 1)
	var new_pos_and_points = Util.lerp_through_points(
		sprite.global_position, _target_pos, _target_points, weight
	)
	var new_pos: Vector2 = new_pos_and_points[0]
	for child in movable_children:
		child.global_position = new_pos
	var prev_target_points := _target_points
	_target_points = new_pos_and_points[1]
	_add_temp_colliders_to_points_moved(prev_target_points, _target_points)


func _add_temp_colliders_to_points_moved(old_points: PoolVector2Array, new_points: PoolVector2Array) -> void:
	var points_moved := _get_points_moved(old_points, new_points)
	for point in points_moved:
		_add_temp_collider(point)


func _get_points_moved(old_points: PoolVector2Array, new_points: PoolVector2Array) -> PoolVector2Array:
	var points_moved := PoolVector2Array()
	for point in old_points:
		if point in new_points:
			return points_moved
		points_moved.append(point)
	return points_moved


func _add_temp_collider(pos: Vector2) -> void:
	var temp_collider: CollisionShape2D = collider.duplicate()
	add_child(temp_collider)
	temp_collider.global_position = pos
	temp_collider.add_to_group(TEMP_COLLIDER_GROUP_NAME)


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
	_add_temp_collider(global_position)
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
