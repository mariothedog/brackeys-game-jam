class_name Bullet
extends Area2D

var velocity := Vector2.ZERO


func _physics_process(delta: float) -> void:
	position += velocity * delta