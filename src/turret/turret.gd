extends Sprite

signal bullet_spawned(bullet)

const BULLET_SCENE := preload("res://bullet/bullet.tscn")

const BULLET_SPEED := 300.0

onready var gun: Sprite = $Gun
onready var barrel: Position2D = $Gun/Barrel


func shoot(global_pos: Vector2, dir: Vector2) -> void:
	var bullet := BULLET_SCENE.instance()
	bullet.global_position = global_pos
	bullet.velocity = dir * BULLET_SPEED
	bullet.rotation = dir.angle()
	emit_signal("bullet_spawned", bullet)


func _on_Shoot_timeout() -> void:
	var dir := Vector2.RIGHT.rotated(gun.rotation)
	shoot(barrel.global_position, dir)
