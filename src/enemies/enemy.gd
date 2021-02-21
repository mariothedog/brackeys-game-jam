extends Area2D

signal died

var dead := false
var speed: float
var path: PoolVector2Array setget _set_path


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	var displacement := speed * delta
	move_along_path(displacement)
	if not path:
		explode()


func move_along_path(dist: float) -> void:
	var start_point := position
	for i in path.size():
		var dist_to_next := start_point.distance_to(path[0])
		if dist <= dist_to_next and dist >= 0.0:
			position = start_point.linear_interpolate(path[0], dist / dist_to_next)
			break
		elif dist < 0.0:
			position = path[0]
			set_physics_process(false)
			break
		dist -= dist_to_next
		start_point = path[0]
		path.remove(0)


func explode() -> void:
	if dead:
		return
	dead = true
	VFX.spawn_particles(VFX.ParticleSystems.ENEMY_EXPLOSION, global_position)
	SFX.play_sfx(SFX.Sounds.ENEMY_EXPLODE)
	queue_free()
	emit_signal("died")


func _set_path(value) -> void:
	path = value
	if not path:
		return
	set_physics_process(true)
