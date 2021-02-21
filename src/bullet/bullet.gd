extends Area2D

var friendly_turrets := []  # List of turrets the bullet will phase through
var dead := false
var velocity := Vector2.ZERO


func _physics_process(delta: float) -> void:
	position += velocity * delta


func explode() -> void:
	if dead:
		return
	dead = true
	VFX.spawn_particles(VFX.ParticleSystems.BULLET_EXPLOSION, global_position)
	queue_free()


func _on_Bullet_area_entered(area: Area2D) -> void:
	if area in friendly_turrets or dead:
		return
	area.explode()
	explode()


func _on_Bullet_body_entered(_body: TileMap) -> void:
	if dead:
		return
	SFX.play_sfx(SFX.Sounds.BULLET_HIT_TILE)
	explode()
