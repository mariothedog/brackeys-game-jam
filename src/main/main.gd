extends Node

onready var level: TileMap = $Level
export var dict := {}

onready var step_delay: Timer = $StepDelay
onready var enemies: Node2D = $Level/Enemies
onready var bullets: Node2D = $Turrets/Bullets
onready var placed_turrets: Node2D = $Turrets/PlacedTurrets


func _ready() -> void:
	var level_data := load("res://levels/resources/level_debug.tres")
	level.build_level(level_data)
# warning-ignore:return_value_discarded
	Signals.connect("start_pressed", self, "_start")
# warning-ignore:return_value_discarded
	Signals.connect("stop_pressed", self, "_stop")


func _start() -> void:
	step_delay.start()
	for turret in placed_turrets.get_children():
		turret.disable_sight_lines()


func _stop() -> void:
	step_delay.stop()
	Util.queue_free_children(enemies)
	Util.queue_free_children(bullets)
	for turret in placed_turrets.get_children():
		turret.enable_sight_lines()
