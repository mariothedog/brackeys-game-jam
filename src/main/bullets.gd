class_name Bullets
extends Node2D


func move_bullets(num: int) -> void:
	for bullet in get_children():
		bullet.move(num)
