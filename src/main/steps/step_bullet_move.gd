class_name StepBulletMove
extends Step


func is_valid(_should_simulate: bool) -> bool:
	return Global.bullets.get_child_count() > 0


func execute() -> void:
	var step_index_and_num_merged: Array = StepManager.merge_steps(Global.steps, Global.step_index)
	Global.step_index = step_index_and_num_merged[0]
	var num_merged: int = step_index_and_num_merged[1]
	Global.bullets.move(num_merged + 1)

	var last_bullet := Global.bullets.get_last()
# warning-ignore:return_value_discarded
	last_bullet.connect("stopped_moving", self, "emit_signal", ["finished"], CONNECT_ONESHOT)
