class_name Enemies
extends Node

signal enemy_reached_end_of_path(enemy)
signal enemy_exploded(enemy)

const ENEMY_SCENE = preload("res://enemies/enemy.tscn")

var paths: Array setget _set_paths
var path_index := 0

var _num_paths: int


func move(num: int) -> void:
	for enemy in get_children():
		enemy.update_position_along_path(num)


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
