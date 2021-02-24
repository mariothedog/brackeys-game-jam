extends Node

onready var level: TileMap = $Level
export var dict := {}


func _ready() -> void:
	var level_data := load("res://levels/resources/level_debug.tres")
	level.build_level(level_data)
