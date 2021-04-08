class_name Bullets
extends Node2D


func move(num: int) -> void:
	for bullet in get_children():
		bullet.move(num)


func get_last() -> Bullet:
	return get_child(get_child_count() - 1) as Bullet
