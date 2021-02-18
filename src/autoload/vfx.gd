extends Node2D

const ParticleSystems := {
	BULLET_EXPLOSION = preload("res://bullet/explosion.tscn")
}


func _ready() -> void:
	z_index = 1


func spawn_particles(particles_scene: Resource, global_pos: Vector2):
	var particles: CPUParticles2D = particles_scene.instance()
	particles.global_position = global_pos
	add_child(particles)
	particles.start()
