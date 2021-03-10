extends HBoxContainer

onready var start: TextureButton = $Start
onready var stop: TextureButton = $Stop


func _on_Start_pressed() -> void:
	start.disabled = true
	stop.disabled = false
	Signals.emit_signal("start_pressed")


func _on_Stop_pressed() -> void:
	start.disabled = false
	stop.disabled = true
	Signals.emit_signal("stop_pressed")
