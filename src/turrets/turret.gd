class_name Turret
extends Area2D

var is_draggable := true


func _on_Turret_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (not event is InputEventMouseButton or
		event.button_index != BUTTON_LEFT or
		not is_draggable):
		return
	if event.is_pressed():
		Signals.emit_signal("draggable_turret_button_down", self)
	else:
		Signals.emit_signal("draggable_turret_button_up", self)
