extends Node

var level := 1 setget _set_level


func _set_level(value) -> void:
	level = value
	get_tree().change_scene("res://levels/level%s.tscn" % level)
