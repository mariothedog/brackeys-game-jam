class_name StepEnemyMove
extends Step


func is_valid(_should_simulate: bool) -> bool:
	return Global.enemies.get_child_count() > 0


func execute() -> void:
	Global.enemies.move_enemies()
	var last_enemy := Global.enemies.get_last()
# warning-ignore:return_value_discarded
	last_enemy.connect("stopped_moving", self, "emit_signal", ["finished"], CONNECT_ONESHOT)
