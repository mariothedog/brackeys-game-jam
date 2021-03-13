class_name Enemies
extends Node

signal enemy_reached_end_of_path(enemy)

const ENEMY_SCENE = preload("res://enemies/enemy.tscn")

var paths: Array setget _set_paths
var path_index := 0

var _num_paths: int


func update_enemy_positions() -> void:
	for enemy in get_children():
		enemy.update_position_along_path()


func spawn_enemy() -> void:
	var enemy: Enemy = ENEMY_SCENE.instance()
	enemy.path = paths[path_index]
# warning-ignore:return_value_discarded
	enemy.connect("reached_end_of_path", self, "_on_enemy_reached_end_of_path", [enemy])
	path_index = (path_index + 1) % _num_paths
	add_child(enemy)


func _set_paths(value: Array) -> void:
	paths = value
	_num_paths = len(paths)


func _on_enemy_reached_end_of_path(enemy: Enemy) -> void:
	emit_signal("enemy_reached_end_of_path", [enemy])


func _on_StepDelay_timeout() -> void:
	# It's important that the enemy positions are updated before an enemy is
	# spawned.
	# If an enemy spawns and then a step occurs immediately after then the enemy
	# will go straight to the path's second tile.
	update_enemy_positions()
	spawn_enemy()
