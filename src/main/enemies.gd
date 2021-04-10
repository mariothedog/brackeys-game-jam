class_name Enemies
extends Node

signal enemy_reached_end_of_path(enemy)
signal enemy_exploded(enemy)
signal all_stopped_moving

const ENEMY_SCENE = preload("res://enemies/enemy.tscn")

var paths: Array setget _set_paths
var path_index := 0

var _num_paths: int
var _num_left_till_all_stopped: int


func reset() -> void:
	Util.queue_free_children(self)
	for connection in get_signal_connection_list("all_stopped_moving"):
		var target: Object = connection.target
		var method: String = connection.method
		disconnect("all_stopped_moving", target, method)


func move(num: int) -> void:
	_num_left_till_all_stopped = get_child_count()
	for enemy in get_children():
		enemy.update_position_along_path(num)
		enemy.connect("stopped_moving", self, "_on_enemy_stopped_moving", [], CONNECT_ONESHOT)


func spawn_enemy() -> void:
	var enemy: Enemy = ENEMY_SCENE.instance()
	enemy.path = paths[path_index]
# warning-ignore:return_value_discarded
	enemy.connect("reached_end_of_path", self, "_on_enemy_reached_end_of_path", [enemy])
# warning-ignore:return_value_discarded
	enemy.connect("exploded", self, "_on_enemy_exploded", [enemy])
	path_index = (path_index + 1) % _num_paths
	add_child(enemy)


func get_last() -> Enemy:
	return get_child(get_child_count() - 1) as Enemy


func _set_paths(value: Array) -> void:
	paths = value
	_num_paths = len(paths)


func _on_enemy_reached_target(enemy: Enemy) -> void:
	emit_signal("enemy_reached_target", enemy)


func _on_enemy_reached_end_of_path(enemy: Enemy) -> void:
	emit_signal("enemy_reached_end_of_path", enemy)


func _on_enemy_exploded(enemy: Enemy) -> void:
	emit_signal("enemy_exploded", enemy)


func _on_enemy_stopped_moving() -> void:
	_num_left_till_all_stopped -= 1
	if _num_left_till_all_stopped == 0:
		emit_signal("all_stopped_moving")
