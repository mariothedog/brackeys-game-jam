extends Node

onready var level: TileMap = $Level
export var dict := {}


func _ready() -> void:
	var level_data := load("res://levels/resources/level_debug.tres")
	level.build_level(level_data)
# warning-ignore:return_value_discarded
	Signals.connect("start_pressed", self, "_start")
# warning-ignore:return_value_discarded
	Signals.connect("stop_pressed", self, "_stop")


func _start() -> void:
	print("Start!")


func _stop() -> void:
	print("Stop!")
