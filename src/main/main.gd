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
var _num_enemies_left: int
var _num_enemies_spawned_in_group := 0
var _num_enemies_dead := 0 setget _set_num_enemies_dead
var _step_index := 0
var _turn_num := 0
var _last_step_start_time: int

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
onready var step_delay_timer: Timer = $StepDelay


func _ready() -> void:
	Global.min_step_delay_ms = initial_min_step_delay_ms
	Global.step_speed = initial_step_speed
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
	if _is_valid_step_turret_shoot(_step_index):
		turrets.charge_up_guns()
	_last_step_start_time = OS.get_ticks_msec()
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
	_step_index = 0
	_turn_num = 0
	_num_enemies_spawned_in_group = 0
	_num_enemies_dead = 0
	hud.highlight_step_labels(-1)
	if not _level_data:
		push_warning("Attempted to reset but the level data is invalid")
		return
	lives.num_lives = _level_data.num_lives
	_num_enemies_left = _level_data.num_enemies


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
	if not _level_data.steps:
		push_warning("Attempted to go to level %s but it has no steps" % num)
	_reset()
	hud.set_step_labels(_level_data.steps)
	item.num_left = _level_data.num_turrets
	level.build_level(_level_data)
	level_label.text = FORMAT_LEVEL_LABEL % num


func _set_num_enemies_dead(value: int) -> void:
	_num_enemies_dead = value
	if value == _level_data.num_enemies:
		_go_to_next_level()


func _on_stop_pressed() -> void:
	_stop()
	_reset()


func _on_ran_out_of_lives() -> void:
	_force_stop()
	_reset()


func _on_Enemies_enemy_reached_end_of_path(enemy: Enemy) -> void:
	lives.damage(enemy.DAMAGE)
	enemy.queue_free()
	self._num_enemies_dead += 1


func _on_Enemies_enemy_exploded(_enemy: Enemy) -> void:
	self._num_enemies_dead += 1


func _get_valid_step_index(step_index: int, should_simulate: bool) -> int:
	var is_valid := false
	while not is_valid:
		step_index %= _level_data.steps.size()
		var step: int = _level_data.steps[step_index]
		match step:
			Constants.StepTypes.TURRET_SHOOT:
				is_valid = placed_turrets.get_child_count() > 0
			Constants.StepTypes.BULLET_MOVE:
				is_valid = bullets.get_child_count() > 0
			Constants.StepTypes.ENEMY_SPAWN:
				if _num_enemies_spawned_in_group == _level_data.enemy_group_size:
					is_valid = false
					if not should_simulate:
						_num_enemies_spawned_in_group = 0  # Remove?
				else:
					is_valid = _num_enemies_left > 0 and enemies.paths
			Constants.StepTypes.ENEMY_MOVE:
				is_valid = enemies.get_child_count() > 0
		if not is_valid:
			step_index += 1
	return step_index


func _get_next_valid_step_index(step_index: int, should_simulate: bool) -> int:
	return _get_valid_step_index(step_index + 1, should_simulate)


func _is_valid_step_turret_shoot(step_index: int) -> bool:
	var next_step_index := _get_valid_step_index(step_index, true)
	return _level_data.steps[next_step_index] == Constants.StepTypes.TURRET_SHOOT


func _get_num_step() -> int:
	var step: int = _level_data.steps[_step_index]
	var num := 1
	var is_consecutive := true
	while is_consecutive:
		var next_step_index := _get_next_valid_step_index(_step_index, true)
		var next_step: int = _level_data.steps[next_step_index]
		is_consecutive = next_step == step
		if is_consecutive:
			_step_index = next_step_index
			num += 1
	return num


func _start_step() -> void:
	_last_step_start_time = OS.get_ticks_msec()
	_step_index = _get_valid_step_index(_step_index, false)
	var step: int = _level_data.steps[_step_index]
	hud.highlight_step_labels(_step_index)
	match step:
		Constants.StepTypes.TURRET_SHOOT:
			# If there are bullet move turns after this one they should all
			# be executed in one turn
			turrets.shoot_turrets(bullets, level.cell_size)
			var next_step_index := _get_next_valid_step_index(_step_index, false)
			var next_step: int = _level_data.steps[next_step_index]
			if next_step == Constants.StepTypes.BULLET_MOVE:
				_step_index = next_step_index
				var num := _get_num_step()
				_move_bullets_step(num)
			else:
				_start_step_delay()
		Constants.StepTypes.BULLET_MOVE:
			var num := _get_num_step()
			_move_bullets_step(num)
		Constants.StepTypes.ENEMY_SPAWN:
			_num_enemies_spawned_in_group += 1
			_num_enemies_left -= 1
			enemies.spawn_enemy()
			_start_step_delay()
		Constants.StepTypes.ENEMY_MOVE:
			enemies.move_enemies()
			var num_enemies := enemies.get_child_count()
			var last_enemy := enemies.get_child(num_enemies - 1)
# warning-ignore:return_value_discarded
			last_enemy.connect("stopped_moving", self, "_start_step_delay", [], CONNECT_ONESHOT)
	_step_index += 1
	_turn_num += 1
	if _is_valid_step_turret_shoot(_step_index):
		turrets.charge_up_guns()


func _move_bullets_step(bullet_move_tile_num: int) -> void:
	bullets.move_bullets(bullet_move_tile_num)
	var num_bullets := bullets.get_child_count()
	var last_bullet := bullets.get_child(num_bullets - 1)
# warning-ignore:return_value_discarded
	last_bullet.connect("stopped_moving", self, "_start_step_delay", [], CONNECT_ONESHOT)


func _start_step_delay() -> void:
	var time_since_last_step := OS.get_ticks_msec() - _last_step_start_time
	var delay := max(Global.min_step_delay_ms - time_since_last_step, 0)
	var delay_sec := delay / 1000.0
	step_delay_timer.start(delay_sec)


func _on_StepDelay_timeout() -> void:
	_start_step()


func _on_speed_pressed(button_pressed: bool) -> void:
	if button_pressed:
		Global.min_step_delay_ms = sped_up_min_step_delay_ms
		Global.step_speed = sped_up_step_speed
	else:
		Global.min_step_delay_ms = normal_min_step_delay_ms
		Global.step_speed = normal_step_speed
