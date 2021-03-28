class_name Bullets
extends Node2D


func move_bullets() -> void:
	for bullet in get_children():
		bullet.move()
