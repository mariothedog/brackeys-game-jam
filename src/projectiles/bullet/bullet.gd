class_name Bullet
extends Area2D

var friendly_turrets := []  # Turrets the bullet won't hurt
#var velocity := Vector2.ZERO
var dir: Vector2

var _target_pos: Vector2

onready var sprite: Sprite = $Sprite


func _ready() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	if sprite.global_position.is_equal_approx(_target_pos):
		set_physics_process(false)
		sprite.position = Vector2.ZERO
		return
	sprite.global_position = sprite.global_position.linear_interpolate(_target_pos, 0.6)


func move(amount: Vector2) -> void:
	_target_pos = global_position + dir * amount
	var prev_global_pos := global_position
	global_position = _target_pos
	sprite.global_position = prev_global_pos
	set_physics_process(true)


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
