extends Node

onready var level: Level = $Level
onready var step_delay: Timer = $StepDelay
onready var enemies: Enemies = $Level/Enemies
onready var bullets: Node2D = $Turrets/Bullets
onready var placed_turrets: Node2D = $Turrets/PlacedTurrets
onready var hud: HUD = $HUDLayer/HUD
onready var lives: Lives = $HUDLayer/HUD/Lives
onready var start_button: TextureButton = $HUDLayer/HUD/Buttons/Start
onready var stop_button: TextureButton = $HUDLayer/HUD/Buttons/Stop


func _ready() -> void:
	var level_data := load("res://levels/resources/level_debug.tres")
	level.build_level(level_data)
# warning-ignore:return_value_discarded
	Signals.connect("start_pressed", self, "_start")
# warning-ignore:return_value_discarded
	Signals.connect("stop_pressed", self, "_stop")


func _start() -> void:
	hud.slide_inventory_in()
	level.start()
	step_delay.start()
	for turret in placed_turrets.get_children():
		turret.toggle_sight_lines(false)
	if not Signals.is_connected("ran_out_of_lives", self, "_force_stop"):
		# Signal is deferred so the force stop happens after the lives have been set to 0
		# Signal is oneshot so there is no chance of two enemies trigerring force stop simultaneously
# warning-ignore:return_value_discarded
		Signals.connect(
			"ran_out_of_lives", self, "_force_stop", [], CONNECT_DEFERRED + CONNECT_ONESHOT
		)
	Global.is_running = true


func _stop() -> void:
	step_delay.stop()
	level.stop()
	lives.reset()
	Util.queue_free_children(enemies)
	Util.queue_free_children(bullets)
	for turret in placed_turrets.get_children():
		if turret.level > 0:
			turret.enable()
	Global.is_running = false


func _force_stop() -> void:
	start_button.disabled = false
	stop_button.disabled = true
	_stop()


func _on_Enemies_enemy_reached_end_of_path(enemy: Enemy) -> void:
	lives.damage(enemy.DAMAGE)
	enemy.queue_free()
