extends Area2D

signal bullet_spawned(bullet)

const BULLET_SCENE := preload("res://bullet/bullet.tscn")
const BULLET_SPEED := 300.0

var level := 1

onready var gun: Sprite = $Gun
onready var shoot_sfx: AudioStreamPlayer = $ShootSFX
onready var shoot_timer: Timer = $Shoot


func _ready() -> void:
	if level > gun.hframes:
		push_error("Turret level is greater than the number of gun frames available")
		return
	gun.frame = level - 1


func shoot() -> void:
	for i in gun.get_child_count():
		var barrel = gun.get_child(i)
		if i >= level:
			continue
		var dir: Vector2 = barrel.position.normalized().rotated(gun.rotation)
		var bullet := BULLET_SCENE.instance()
		bullet.global_position = barrel.global_position
		bullet.velocity = dir * BULLET_SPEED
		bullet.rotation = dir.angle()
		bullet.friendly_turrets.append(self)
		emit_signal("bullet_spawned", bullet)
	shoot_sfx.pitch_scale = rand_range(0.95, 1.05)
	shoot_sfx.play()


func explode() -> void:
	VFX.spawn_particles(VFX.ParticleSystems.TURRET_EXPLOSION, global_position)
	SFX.play_sfx(SFX.Sounds.TURRET_EXPLODE)
	queue_free()


func _on_Shoot_timeout() -> void:
	shoot()
