extends Node

const ENEMY_SCENE = preload("res://enemies/enemy.tscn")

var paths: Array setget _set_paths

var _num_paths: int
var _path_index := 0


func update_enemy_positions() -> void:
	for enemy in get_children():
		enemy.update_position_along_path()


func spawn_enemy() -> void:
	var enemy := ENEMY_SCENE.instance()
	enemy.path = paths[_path_index]
	_path_index = (_path_index + 1) % _num_paths
	add_child(enemy)


func _set_paths(value: Array) -> void:
	paths = value
	_num_paths = len(paths)


func _on_StepDelay_timeout() -> void:
	# It's important that the enemy positions are updated before an enemy is spawned
	# If an enemy spawns and then a step occurs immediately after then the enemy
	# will go straight to the path's second tile
	update_enemy_positions()
	spawn_enemy()
