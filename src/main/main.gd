extends Node

const FORMAT_LEVEL_PATH := "res://levels/resources/level_%s.tres"
const FORMAT_LEVEL_LABEL := "level: %s"
const STEP_RATE := 1.0
const ENEMY_STEP_TO_TURRET_STEP_RATIO := 2

export var level_num := 1

var _level_data: LevelData
var _num_enemies_left: int
var _num_enemies_dead := 0 setget _set_num_enemies_dead
var _turn_num := 0

onready var level: Level = $Level
onready var enemies: Enemies = $Level/Enemies
onready var enemy_spawn_indicators: Node2D = $Level/EnemySpawnIndicators
onready var turrets: Turrets = $Turrets
onready var bullets: Bullets = $Turrets/Bullets
onready var placed_turrets: Node2D = $Turrets/PlacedTurrets
onready var hud: HUD = $HUDLayer/HUD
onready var level_label: Label = $HUDLayer/HUD/VBoxContainer/LevelMargin/Level
onready var lives: Lives = $HUDLayer/HUD/VBoxContainer/Lives
onready var item: Item = $HUDLayer/HUD/Inventory/ItemsMargin/Items/Item
onready var start_button: TextureButton = $HUDLayer/HUD/Buttons/Start
onready var stop_button: TextureButton = $HUDLayer/HUD/Buttons/Stop
onready var step_delay: Timer = $StepDelay


func _ready() -> void:
	step_delay.wait_time = STEP_RATE / ENEMY_STEP_TO_TURRET_STEP_RATIO
	_go_to_level(level_num)
# warning-ignore:return_value_discarded
	Signals.connect("start_pressed", self, "_start")
# warning-ignore:return_value_discarded
	Signals.connect("stop_pressed", self, "_stop")


func _start() -> void:
	hud.slide_inventory_in()
	level.start()
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
	step_delay.start()


func _stop() -> void:
	step_delay.stop()
	level.stop()
	_reset()
	Util.queue_free_children(enemies)
	Util.queue_free_children(bullets)
	for turret in placed_turrets.get_children():
		if turret.level > 0:
			turret.enable()
	Global.is_running = false


func _reset() -> void:
	_turn_num = 0
	lives.num_lives = _level_data.num_lives
	_num_enemies_left = _level_data.num_enemies
	_num_enemies_dead = 0


func _force_stop() -> void:
	start_button.disabled = false
	stop_button.disabled = true
	_stop()


func _go_to_next_level() -> void:
	level_num += 1
	_go_to_level(level_num)


func _go_to_level(num: int) -> void:
	Util.queue_free_children(enemy_spawn_indicators)
	Util.queue_free_children(placed_turrets)
	_level_data = load(FORMAT_LEVEL_PATH % num)
	_force_stop()
	item.num_left = _level_data.num_turrets
	_reset()
	level.build_level(_level_data)
	level_label.text = FORMAT_LEVEL_LABEL % num


func _set_num_enemies_dead(value: int) -> void:
	_num_enemies_dead = value
	if value == _level_data.num_enemies:
		_go_to_next_level()


func _on_Enemies_enemy_reached_end_of_path(enemy: Enemy) -> void:
	lives.damage(enemy.DAMAGE)
	enemy.queue_free()
	self._num_enemies_dead += 1


func _on_Enemies_enemy_exploded(_enemy: Enemy) -> void:
	self._num_enemies_dead += 1


func _on_StepDelay_timeout() -> void:
	# The order that these methods are called in matters
	enemies.update_enemy_positions()
	if _num_enemies_left > 0:
		_num_enemies_left -= 1
		enemies.spawn_enemy()
	if _turn_num % ENEMY_STEP_TO_TURRET_STEP_RATIO == 0:
		turrets.shoot_turrets(bullets)
		bullets.move_bullets(level.cell_size)
	_turn_num += 1
