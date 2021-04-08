extends Node

# warning-ignore-all:unused_class_variable

var is_running := false
var selected_turret: Turret
var is_aiming := false
var min_step_delay_ms := 1.0
var step_speed := 1.0

var level: Level
var enemies: Enemies
var turrets: Turrets
var bullets: Bullets
var placed_turrets: Node
var steps: Array
var step_index := 0
var num_enemies_left: int
var num_enemies_dead := 0
var enemy_group_size_max: int
var current_enemy_group_size := 0


func reset(num_enemies: int, enemy_group_size: int) -> void:
	step_index = 0
	num_enemies_left = num_enemies
	num_enemies_dead = 0
	enemy_group_size_max = enemy_group_size
	current_enemy_group_size = 0
