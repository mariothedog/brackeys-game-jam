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

#	var next_step_index: int = StepManager.get_valid_step_index(
#		Global.steps, Global.step_index + 1, false
#	)
#	var next_step: Step = Global.steps[next_step_index]
#	if next_step is StepEnemyMove:
#		var step_index_and_num_skipped: Array = StepManager.merge_steps(
#			Global.steps, next_step_index
#		)
#		var num_merged: int = step_index_and_num_skipped[1]
#		Global.step_index = step_index_and_num_skipped[0]
#		Global.enemies.move(num_merged + 1)
## warning-ignore:return_value_discarded
#		Global.enemies.connect(
#			"all_stopped_moving", self, "emit_signal", ["finished"], CONNECT_ONESHOT
#		)
#	else:
#		emit_signal("finished")
	emit_signal("finished")
