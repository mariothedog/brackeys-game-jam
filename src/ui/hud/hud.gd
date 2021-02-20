extends CanvasLayer

signal start_pressed
signal stop_pressed

onready var label_level: Label = $Control/LevelMargin/Level
onready var start: TextureButton = $Control/Buttons/Start
onready var stop: TextureButton = $Control/Buttons/Stop


func _ready() -> void:
	label_level.text = "Level: %s" % Global.level
	start.disabled = false
	stop.disabled = true


func _on_Start_pressed() -> void:
	start.disabled = true
	stop.disabled = false
	emit_signal("start_pressed")


func _on_Stop_pressed() -> void:
	start.disabled = false
	stop.disabled = true
	emit_signal("stop_pressed")
