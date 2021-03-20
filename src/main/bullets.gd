class_name Bullets
extends Node2D


func move_bullets(amount: Vector2) -> void:
	for bullet in get_children():
		bullet.move(amount)
