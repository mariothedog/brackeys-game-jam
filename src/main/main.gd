extends Node

onready var level: Level = $Level
onready var step_delay: Timer = $StepDelay
onready var enemies: Enemies = $Level/Enemies
onready var bullets: Node2D = $Turrets/Bullets
onready var placed_turrets: Node2D = $Turrets/PlacedTurrets
onready var hud: HUD = $HUDLayer/HUD


func _ready() -> void:
	var level_data := load("res://levels/resources/level_debug.tres")
	level.build_level(level_data)
# warning-ignore:return_value_discarded
	Signals.connect("start_pressed", self, "_start")
# warning-ignore:return_value_discarded
	Signals.connect("stop_pressed", self, "_stop")


func _start() -> void:
	hud.slide_inventory_in()
	step_delay.start()
	for turret in placed_turrets.get_children():
		turret.toggle_sight_lines(false)
	Global.is_running = true


func _stop() -> void:
	step_delay.stop()
	Util.queue_free_children(enemies)
	Util.queue_free_children(bullets)
	for turret in placed_turrets.get_children():
		if turret.level > 0:
			turret.enable()
	enemies.path_index = 0
	Global.is_running = false
