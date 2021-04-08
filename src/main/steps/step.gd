class_name Step

# warning-ignore:unused_signal
signal finished


func is_valid(_should_simulate: bool) -> bool:
	push_warning("Attempted to validate a step but is_valid() has not been overriden")
	return false


func execute() -> void:
	push_warning("Attempted to execute a step but execute() has not been overriden")


func charge_up() -> void:  # Runs when the previous step starts
	return
