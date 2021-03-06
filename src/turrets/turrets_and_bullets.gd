extends Node

onready var bullets: Node2D = $Bullets
onready var turrets: Node2D = $Turrets


func _on_StepDelay_timeout() -> void:
	for turret in turrets.get_children():
		turret.shoot()


func _on_Turrets_turret_added(turret) -> void:
	turret.bullets_node = bullets
