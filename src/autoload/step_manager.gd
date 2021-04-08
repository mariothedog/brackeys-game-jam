extends Node

enum StepTypes {
	TURRET_SHOOT,
	BULLET_MOVE,
	ENEMY_SPAWN,
	ENEMY_MOVE,
}

const STEP_TYPES_TO_STEPS := {
	StepTypes.TURRET_SHOOT: StepTurretShoot,
	StepTypes.BULLET_MOVE: StepBulletMove,
	StepTypes.ENEMY_SPAWN: StepEnemySpawn,
	StepTypes.ENEMY_MOVE: StepEnemyMove,
}


func get_steps_from_step_types(step_types: Array) -> Array:
	var steps := []
	for type in step_types:
		var step: Step = STEP_TYPES_TO_STEPS[type].new()
		steps.append(step)
	return steps


func get_valid_step_index(steps: Array, step_index: int, should_simulate: bool) -> int:
	var is_valid := false
	while not is_valid:
		step_index %= steps.size()
		var step: Step = steps[step_index]
		is_valid = step.is_valid(should_simulate)
		if not is_valid:
			step_index += 1
	return step_index


func merge_steps(steps: Array, step_index: int) -> Array:
	# Returns [new step index, number of steps merged]
	var step: Step = steps[step_index]
	var num_merged := 0
	var is_consecutive := true
	while is_consecutive:
		var next_step_index := get_valid_step_index(steps, step_index + 1, false)
		var next_step: Step = steps[next_step_index]
		is_consecutive = _are_steps_equal(step, next_step)
		if is_consecutive:
			step_index = next_step_index
			num_merged += 1
	return [step_index, num_merged]


func _are_steps_equal(a: Step, b: Step) -> bool:
	return a.get_script() == b.get_script()
