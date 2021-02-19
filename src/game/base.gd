extends Area2D

signal hit


func _on_Base_area_entered(_area: Area2D) -> void:
	emit_signal("hit")
