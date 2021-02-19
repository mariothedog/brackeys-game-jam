extends Node2D

onready var particle_systems := get_children()


func _ready() -> void:
	for system in particle_systems:
		system.connect("tree_exited", self, "_on_particle_system_tree_exited")


func start() -> void:
	for system in particle_systems:
		system.start()


func _on_particle_system_tree_exited() -> void:
	if not get_child_count():
		queue_free()
