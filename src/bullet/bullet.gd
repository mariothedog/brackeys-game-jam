extends Area2D

var velocity := Vector2.ZERO


func _physics_process(delta: float) -> void:
	position += velocity * delta


func explode() -> void:
	queue_free()


func _on_Bullet_area_entered(area: Area2D) -> void:
	area.explode()
	explode()


func _on_Bullet_body_entered(_body: Node) -> void:
	explode()
