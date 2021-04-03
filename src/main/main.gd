extends Node

const FORMAT_LEVEL_LABEL := "level: %s"

export var level_num := 1

var _level_data: LevelData
var _num_enemies_left: int
var _num_enemies_spawned_in_group := 0
var _num_enemies_dead := 0 setget _set_num_enemies_dead
var _step_index := 0
var _turn_num := 0
var _last_turret: Turret

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
	_go_to_level(level_num)
# warning-ignore:return_value_discarded
	Signals.connect("start_pressed", self, "_start")
# warning-ignore:return_value_discarded
	Signals.connect("stop_pressed", self, "_on_stop_pressed")


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
	step_delay_timer.start()


func _stop() -> void:
	step_delay_timer.stop()
	level.stop()
	turrets.stop_turret_shooting_anims()
	if _last_turret:
#		Util.disconnect_safe(_last_turret, "shot", bullets, "move_bullets")
		Util.disconnect_safe(_last_turret, "shot", self, "_move_bullets_step")
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


func _get_valid_step() -> int:
	var step: int
	var is_valid := false
	while not is_valid:
		_step_index %= _level_data.steps.size()
		step = _level_data.steps[_step_index]
		match step:
			Constants.StepTypes.BULLET_MOVE:
				is_valid = bullets.get_child_count() > 0
			Constants.StepTypes.TURRET_SHOOT:
				is_valid = placed_turrets.get_child_count() > 0
			Constants.StepTypes.ENEMY_SPAWN:
				if _num_enemies_spawned_in_group == _level_data.enemy_group_size:
					is_valid = false
					_num_enemies_spawned_in_group = 0
				else:
					is_valid = _num_enemies_left > 0 and enemies.paths
			Constants.StepTypes.ENEMY_MOVE:
				is_valid = enemies.get_child_count() > 0
		if not is_valid:
			_step_index += 1
	return step


func _get_num_step() -> int:
	var step: int = _level_data.steps[_step_index]
	var num := 1
	var is_consecutive := true
	while is_consecutive:
		var next_step_index := _get_next_step_index()
		var next_step: int = _level_data.steps[next_step_index]
		is_consecutive = next_step == step
		if is_consecutive:
			_step_index = next_step_index
			num += 1
	return num


func _start_step() -> void:
	var step := _get_valid_step()
	hud.highlight_step_labels(_step_index)
	match step:
		Constants.StepTypes.ENEMY_SPAWN:
			_num_enemies_spawned_in_group += 1
			_num_enemies_left -= 1
			enemies.spawn_enemy()
			step_delay_timer.start()
		Constants.StepTypes.ENEMY_MOVE:
			enemies.move_enemies()
			var num_enemies := enemies.get_child_count()
			var last_enemy := enemies.get_child(num_enemies - 1)
# warning-ignore:return_value_discarded
			last_enemy.connect("stopped_moving", step_delay_timer, "start", [], CONNECT_ONESHOT)
		Constants.StepTypes.BULLET_MOVE:
			var num := _get_num_step()
			_move_bullets_step(num)
		Constants.StepTypes.TURRET_SHOOT:
			# If there are bullet move turns after this one they should all
			# be executed in one turn
			turrets.shoot_turrets(bullets, level.cell_size)
			var next_step_index := _get_next_step_index()
			var next_step: int = _level_data.steps[next_step_index]
			if next_step == Constants.StepTypes.BULLET_MOVE:
				_step_index = next_step_index
				var num := _get_num_step()
				# The bullets should only move after *all* the bullets
				# have been shot
				# To ensure that all the bullets have been shot, only the last
				# turret (i.e. the one that shoots last) has its shot signal
				# connected to bullets.move_bullets
# warning-ignore:return_value_discarded
				_last_turret.connect(
					"shot", self, "_move_bullets_step", [num], CONNECT_ONESHOT
				)
	_step_index = _get_next_step_index()
	_turn_num += 1


func _get_next_step_index() -> int:
	return (_step_index + 1) % _level_data.steps.size()


func _on_Turrets_placed(_turret: Turret) -> void:
	var num_turrets := placed_turrets.get_child_count()
	var last_turret := placed_turrets.get_child(num_turrets - 1)
	_last_turret = last_turret


func _move_bullets_step(bullet_move_tile_num: int) -> void:
	bullets.move_bullets(bullet_move_tile_num)
	var num_bullets := bullets.get_child_count()
	var last_bullet := bullets.get_child(num_bullets - 1)
# warning-ignore:return_value_discarded
	last_bullet.connect("stopped_moving", step_delay_timer, "start", [], CONNECT_ONESHOT)


func _on_StepDelay_timeout() -> void:
	_start_step()
