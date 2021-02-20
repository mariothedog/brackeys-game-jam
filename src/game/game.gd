extends Node2D

const TURRET_SCENE := preload("res://turret/turret.tscn")
const ENEMY_SCENE := preload("res://enemies/enemy.tscn")
const TURRET_AIMING_ANGLE_SNAP := deg2rad(45)
const ENEMY_DEATH_AMP := 0.2
const ENEMY_DEATH_FREQ := 15.0
const ENEMY_DEATH_DUR := 3.0

export var num_enemies := 5
export var enemy_spawn_delay := 0.5
export var enemy_speed := 30.0

var _selected_draggable_item: TextureButton
var _drag_offset: Vector2
var _currently_aiming_draggable_item: TextureButton
var _enemy_path: PoolVector2Array
var _num_enemies_spawned := 0

onready var camera: Camera2D = $Camera2D
onready var nav_2d: Navigation2D = $Navigation2D
onready var tilemap: TileMap = $Navigation2D/TileMap
onready var tile_set: TileSet = tilemap.tile_set
onready var enemy_spawn_indicator: Sprite = $EnemySpawnIndicator
onready var enemy_start: Position2D = $EnemyStart
onready var enemy_end: Position2D = $EnemyEnd
onready var bullets: Node = $Bullets
onready var enemies: Node2D = $Enemies
onready var turrets: Node2D = $Turrets
onready var inventory: Node2D = $Inventory
onready var hud: CanvasLayer = $HUD
onready var enemy_spawn_timer: Timer = $EnemySpawn


func _ready() -> void:
	enemy_spawn_timer.wait_time = enemy_spawn_delay
	
	var start_pos := enemy_start.global_position
	var end_pos := enemy_end.global_position
	_enemy_path = nav_2d.get_simple_path(start_pos, end_pos, false)
	# Make path take sharp turns around corners
	# TODO: Unhackify this entire path calculation (good luck)
	for i in range(1, _enemy_path.size() - 1):
		var point := _enemy_path[i]
		var next_point := _enemy_path[i + 1]
		var change := next_point - point
		if change.x == 0 or change.y == 0:
			continue
		var prev_point := _enemy_path[i - 1]
		if point.x == prev_point.x:
			point.y = next_point.y
		elif point.y == prev_point.y:
			point.x = next_point.x
		_enemy_path[i] = point


func _process(_delta: float) -> void:
	if _selected_draggable_item:
		var pos := get_global_mouse_position() + _drag_offset
		_selected_draggable_item.rect_global_position = pos
	elif _currently_aiming_draggable_item:
		var mouse_local_pos: Vector2 = _currently_aiming_draggable_item.base.get_local_mouse_position()
		var angle_to_mouse: float = mouse_local_pos.angle()
		var angle_snapped := stepify(angle_to_mouse, TURRET_AIMING_ANGLE_SNAP)
		_currently_aiming_draggable_item.rotate_to(angle_snapped)
		get_tree().call_group("placed_draggable_turrets", "update_sight_line")


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == BUTTON_LEFT
		and event.is_pressed()
		and _currently_aiming_draggable_item
	):
		_currently_aiming_draggable_item = null


func _place_turret(pos: Vector2, rotation: float, level: int) -> void:
	if level < 1:
		push_error("Turret level must be greater than or equal to 1")
		return

	var turret := TURRET_SCENE.instance()
	turret.global_position = pos
	turret.level = level
	assert(turret.connect("bullet_spawned", self, "_on_bullet_spawned") == OK)
	turrets.add_child(turret)
	turret.gun.rotation = rotation


func _get_draggable_items_at_pos(global_pos: Vector2) -> Array:
	var items := []
	for item in get_tree().get_nodes_in_group("placed_draggable_turrets"):
		if item.draggable.global_position == global_pos:
			items.append(item)
	return items


func _update_draggable_items() -> void:
	var draggable_items_at_pos := {}
	for draggable_item in get_tree().get_nodes_in_group("placed_draggable_turrets"):
		if draggable_item == _selected_draggable_item:
			continue
		if not draggable_items_at_pos.has(draggable_item.rect_global_position):
			draggable_items_at_pos[draggable_item.rect_global_position] = []
		draggable_items_at_pos[draggable_item.rect_global_position].append(draggable_item)

	for pos in draggable_items_at_pos:
		var items: Array = draggable_items_at_pos[pos]
		var num := len(items)
		for i in num:
			var item: TextureButton = items[i]
			if i == num - 1:
				item.level = num
				item.visible = true
			else:
				item.visible = false
				item.level = 0


func _spawn_enemies() -> void:
#	for i in num_enemies:
	_num_enemies_spawned = 0
	_spawn_enemy()
	enemy_spawn_timer.start()


func _spawn_enemy() -> void:
	_num_enemies_spawned += 1
	var enemy := ENEMY_SCENE.instance()
	enemy.global_position = enemy_start.global_position
	enemy.speed = enemy_speed
	enemy.connect("died", self, "_on_enemy_death")
	enemies.add_child(enemy)
	enemy.path = _enemy_path


func _on_EnemySpawn_timeout() -> void:
	_spawn_enemy()
	if _num_enemies_spawned < num_enemies:
		enemy_spawn_timer.start()


func _start() -> void:
	inventory.visible = false
	enemy_spawn_indicator.visible = false
	print("Start")
	for turret in get_tree().get_nodes_in_group("placed_draggable_turrets"):
		turret.disable_sight_blocker()
		if not turret.visible:
			continue
		var pos: Vector2 = turret.rect_global_position + turret.base.position
		_place_turret(pos, turret.gun.rotation, turret.level)
	_spawn_enemies()


func _restart() -> void:
	enemy_spawn_timer.stop()
	inventory.visible = true
	enemy_spawn_indicator.visible = true
	Util.queue_free_children(turrets)
	Util.queue_free_children(bullets)
	Util.queue_free_children(enemies)
	get_tree().call_group("placed_draggable_turrets", "enable_sight_blocker")


func _on_Inventory_draggable_turret_button_down(turret: TextureButton) -> void:
	turret.raise()
	turret.disable_sight_lines()

	_drag_offset = -turret.base.position
	_selected_draggable_item = turret
	if _selected_draggable_item.is_in_group("placed_draggable_turrets"):
		_selected_draggable_item.remove_from_group("placed_draggable_turrets")
		print("Disable via button down")
		turret.disable_sight_blocker()
	_update_draggable_items()
	_selected_draggable_item.level = 1
	_selected_draggable_item.set_physics_process(false)
	get_tree().call_group("placed_draggable_turrets", "update_sight_line")


func _on_Inventory_draggable_turret_button_up(turret: TextureButton) -> void:
	_selected_draggable_item = null

	var tile_pos := tilemap.world_to_map(get_global_mouse_position())
	if tilemap.get_cellv(tile_pos) != tilemap.Tiles.GROUND:
		turret.reset()
		return

	var global_pos_snapped = (
		tilemap.map_to_world(tile_pos)
		+ tilemap.cell_size / 2
		- turret.base.position
	)

	turret.rect_global_position = global_pos_snapped
	turret.add_to_group("placed_draggable_turrets")
	turret.enable_sight_blocker()

	_currently_aiming_draggable_item = turret

	_update_draggable_items()
	turret.enable_sight_lines()


func _on_HUD_start_pressed() -> void:
	_start()


func _on_HUD_stop_pressed() -> void:
	_restart()


func _on_bullet_spawned(bullet: Area2D) -> void:
	bullets.add_child(bullet)


func _on_Base_hit() -> void:
	hud.start.disabled = false
	hud.stop.disabled = true
	_restart()


func _on_enemy_death() -> void:
	camera.shake(ENEMY_DEATH_AMP, ENEMY_DEATH_FREQ, ENEMY_DEATH_DUR)
