class_name Bullet
extends Area2D

var friendly_turrets := []  # Turrets the bullet won't hurt
var velocity := Vector2.ZERO


func _physics_process(delta: float) -> void:
	position += velocity * delta


func explode() -> void:
	if is_queued_for_deletion():
		return
	queue_free()


func _on_Bullet_area_entered(area: Area2D) -> void:
	if is_queued_for_deletion() or area in friendly_turrets:
		return
	explode()
# warning-ignore:unsafe_method_access
	area.explode()


func _on_Bullet_body_entered(_body: TileMap) -> void:
	if is_queued_for_deletion():
		return
	explode()
