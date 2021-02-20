extends Node2D

const ParticleSystems := {
	BULLET_EXPLOSION = preload("res://bullet/bullet_explosion.tscn"),
	TURRET_EXPLOSION = preload("res://turret/turret_explosion.tscn"),
	ENEMY_EXPLOSION = preload("res://enemies/enemy_explosion.tscn")
}


func spawn_particles(particles_scene: Resource, global_pos: Vector2):
	var particle_system: Node2D = particles_scene.instance()
	particle_system.global_position = global_pos
	add_child(particle_system)
	particle_system.start()
