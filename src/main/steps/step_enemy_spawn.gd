class_name StepEnemySpawn
extends Step


func is_valid(should_simulate: bool) -> bool:
	if Global.current_enemy_group_size == Global.enemy_group_size_max:
		if not should_simulate:
			Global.current_enemy_group_size = 0
		return false
	return Global.num_enemies_left > 0 and Global.enemies.paths


func execute() -> void:
	Global.num_enemies_left -= 1
	Global.current_enemy_group_size += 1
	Global.enemies.spawn_enemy()
	emit_signal("finished")
