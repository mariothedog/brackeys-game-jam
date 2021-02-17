extends CanvasLayer

signal start_pressed

onready var control: Control = $Control


func hide() -> void:
	control.visible = false


func _on_Start_pressed() -> void:
	emit_signal("start_pressed")
