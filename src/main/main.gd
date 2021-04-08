extends Node

const FORMAT_LEVEL_LABEL := "level: %s"

export var level_num := 1
export var initial_min_step_delay_ms := 1000.0
export var normal_min_step_delay_ms := 1000.0
export var sped_up_min_step_delay_ms := 500.0
export var initial_step_speed := 1.0
export var normal_step_speed := 1.0
export var sped_up_step_speed := 2.0

var _level_data: LevelData
var _last_step_start_time: int
var _turn_num := 0

onready var level: Level = $Level
onready var enemies: Enemies = $Level/Enemies
onready var enemy_spawn_indicators: Node2D = $Level/EnemySpawnIndicators
onready var turrets: Turrets = $Turrets
onready var bullets: Bullets = $Turrets/Bullets
onready var placed_turrets: Node = $Turrets/PlacedTurrets
onready var hud: HUD = $HUDLayer/HUD
onready var level_label: Label = $HUDLayer/HUD/VBoxContainer/LevelMargin/Level
onready var lives: Lives = $HUDLayer/HUD/VBoxContainer/Lives
onready var item: Item = $HUDLayer/HUD/Inventory/ItemsMargin/Items/Item
onready var start_button: TextureButton = $HUDLayer/HUD/Buttons/Start
onready var stop_button: TextureButton = $HUDLayer/HUD/Buttons/Stop
onready var step_delay_timer: Timer = $StepDelay


func _ready() -> void:
	Global.min_step_delay_ms = initial_min_step_delay_ms
	Global.step_speed = initial_step_speed
	Global.level = level
	Global.enemies = enemies
	Global.turrets = turrets
	Global.bullets = bullets
	Global.placed_turrets = placed_turrets
	_go_to_level(level_num)
# warning-ignore:return_value_discarded
	Signals.connect("start_pressed", self, "_start")
# warning-ignore:return_value_discarded
	Signals.connect("stop_pressed", self, "_on_stop_pressed")
# warning-ignore:return_value_discarded
	Signals.connect("speed_pressed", self, "_on_speed_pressed")


func _start() -> void:
	hud.slide_inventory_in()
	level.start()
	for turret in placed_turrets.get_children():
		turret.toggle_sight_lines(false)
	# Signal is deferred so the force stop happens after the lives have been set to 0
	# Signal is oneshot so there is no chance of two enemies trigerring force stop simultaneously
	Util.connect_safe(
		Signals,
		"ran_out_of_lives",
		self,
		"_on_ran_out_of_lives",
		[],
		CONNECT_DEFERRED + CONNECT_ONESHOT
	)
	Global.is_running = true
	_last_step_start_time = OS.get_ticks_msec()
	var first_step_index: int = StepManager.get_valid_step_index(
		Global.steps, Global.step_index, true
	)
	var next_step: Step = Global.steps[first_step_index]
	next_step.charge_up()
	_start_step_delay()


func _stop() -> void:
	step_delay_timer.stop()
	level.stop()
	turrets.stop_charge_up_anim_anims()
	Util.queue_free_children(enemies)
	Util.queue_free_children(bullets)
	for turret in placed_turrets.get_children():
		if turret.level > 0:
			turret.enable()
	Global.is_running = false


func _reset() -> void:
	_turn_num = 0
	hud.highlight_step_labels(-1)
	if not _level_data:
		push_warning("Attempted to reset but the level data is invalid")
		return
	Global.reset(_level_data.num_enemies, _level_data.enemy_group_size)
	lives.num_lives = _level_data.num_lives


func _on_stop_pressed() -> void:
	_stop()
	_reset()


func _force_stop() -> void:
	start_button.disabled = false
	stop_button.disabled = true
	_stop()


func _go_to_next_level() -> void:
	print("Turns Taken to Complete the Level: ", _turn_num)
	level_num += 1
	_go_to_level(level_num)


func _go_to_level(num: int) -> void:
	Util.queue_free_children(enemy_spawn_indicators)
	Util.queue_free_children(placed_turrets)
	_force_stop()
	_level_data = load(Constants.FORMAT_LEVEL_PATH % num)
	if not _level_data:
		push_warning("Attempted to go to level %s but it wasn't found" % num)
		return
	if not _level_data.step_types:
		push_warning("Attempted to go to level %s but it has no step types" % num)
	_reset()
	Global.steps = StepManager.get_steps_from_step_types(_level_data.step_types)
	for step in Global.steps:
		step.connect("finished", self, "_start_step_delay")
	hud.set_step_labels(_level_data.step_types)
	item.num_left = _level_data.num_turrets
	level.build_level(_level_data)
	level_label.text = FORMAT_LEVEL_LABEL % num


func _on_Enemies_enemy_reached_end_of_path(enemy: Enemy) -> void:
	var is_out_of_lives := lives.damage(enemy.DAMAGE)
	enemy.queue_free()
	Global.num_enemies_dead += 1
	if Global.num_enemies_dead == _level_data.num_enemies and not is_out_of_lives:
		_go_to_next_level()


func _on_ran_out_of_lives() -> void:
	_force_stop()
	_reset()


func _on_Enemies_enemy_exploded(_enemy: Enemy) -> void:
	Global.num_enemies_dead += 1
	if Global.num_enemies_dead == _level_data.num_enemies:
		_go_to_next_level()


func _execute_step() -> void:
	Global.step_index = StepManager.get_valid_step_index(Global.steps, Global.step_index, false)
	hud.highlight_step_labels(Global.step_index)
	var step: Step = Global.steps[Global.step_index]
	step.execute()
	Global.step_index += 1
	_turn_num += 1
	var next_step_index: int = StepManager.get_valid_step_index(
		Global.steps, Global.step_index, true
	)
	var next_step: Step = Global.steps[next_step_index]
	next_step.charge_up()


func _start_step_delay() -> void:
	var time_since_last_step := OS.get_ticks_msec() - _last_step_start_time
	var delay := max(Global.min_step_delay_ms - time_since_last_step, 0)
	var delay_sec := delay / 1000.0
	step_delay_timer.start(delay_sec)


func _on_StepDelay_timeout() -> void:
	_last_step_start_time = OS.get_ticks_msec()
	_execute_step()


func _on_speed_pressed(button_pressed: bool) -> void:
	if button_pressed:
		Global.min_step_delay_ms = sped_up_min_step_delay_ms
		Global.step_speed = sped_up_step_speed
	else:
		Global.min_step_delay_ms = normal_min_step_delay_ms
		Global.step_speed = normal_step_speed
