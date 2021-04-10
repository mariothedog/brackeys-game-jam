class_name StepTurretShoot
extends Step


func is_valid(_should_simulate: bool) -> bool:
	return Global.placed_turrets.get_child_count() > 0


func execute() -> void:
	Global.turrets.shoot(Global.bullets, Global.level.cell_size)
	var next_step_index: int = StepManager.get_valid_step_index(
		Global.steps, Global.step_index + 1, false
	)
	var next_step: Step = Global.steps[next_step_index]
	if next_step is StepBulletMove:
		var step_index_and_num_skipped: Array = StepManager.merge_steps(
			Global.steps, next_step_index
		)
		var num_merged: int = step_index_and_num_skipped[1]
		Global.step_index = step_index_and_num_skipped[0]
		Global.bullets.move(num_merged + 1)
# warning-ignore:return_value_discarded
		Global.bullets.connect(
			"all_stopped_moving", self, "emit_signal", ["finished"], CONNECT_ONESHOT
		)
	else:
		emit_signal("finished")


func charge_up() -> void:  # Runs when the previous step starts
	Global.turrets.charge_up_guns()
