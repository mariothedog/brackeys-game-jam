extends Node2D

const TURRET_SCENE := preload("res://turrets/turret.tscn")

const TURRET_AIMING_ANGLE_SNAP := deg2rad(45)
const TURRET_AIMING_MOUSE_DIST_THRESHOLD := 3.0

export (NodePath) var level_path

var Tiles := TilesManager.new()

var _prev_angle_snapped := 0.0

onready var level: TileMap = get_node(level_path)
onready var bullets: Node2D = $Bullets
onready var placed_turrets: Node2D = $PlacedTurrets
onready var dragging_turret: Sprite = $DraggingTurretLayer/DraggingTurret


func _ready() -> void:
	set_process(false)
	dragging_turret.visible = false
# warning-ignore:return_value_discarded
	Signals.connect("item_button_down", self, "_on_item_button_down")
# warning-ignore:return_value_discarded
	Signals.connect("item_button_up", self, "_on_item_button_up")


func _process(_delta: float) -> void:
	if Global.is_aiming:
		var mouse_pos := Global.selected_turret.get_local_mouse_position()
		if mouse_pos.length() < TURRET_AIMING_MOUSE_DIST_THRESHOLD:
			return
		var angle_to_mouse := mouse_pos.angle()
		var angle_snapped := stepify(angle_to_mouse, TURRET_AIMING_ANGLE_SNAP)
		if angle_snapped != _prev_angle_snapped:
			_prev_angle_snapped = angle_snapped
			Global.selected_turret.rotate_gun_to(angle_snapped)
	else:
		dragging_turret.global_position = get_global_mouse_position()


func _input(event: InputEvent) -> void:
	if (
		not event is InputEventMouseButton
		or event.button_index != BUTTON_LEFT
		or not Global.selected_turret
	):
		return
	if not event.is_pressed():
		_release_turret(Global.selected_turret)
	elif Global.is_aiming:
		set_process(false)
		Global.selected_turret = null
		Global.is_aiming = false


func _select_turret(turret: Turret) -> void:
	dragging_turret.visible = true
	turret.visible = false
	turret.can_shoot = false
	turret.raise()
	turret.can_be_shot = false
	turret.disable_sight_lines()
	turret.gun.rotation = 0
	Global.selected_turret = turret
	set_process(true)


func _release_turret(turret: Turret) -> void:
	dragging_turret.visible = false
	turret.visible = true
	var tile_pos := _get_tile_pos_at_mouse()
	if level.get_cellv(tile_pos) != Tiles.Main.GROUND:
		turret.queue_free()
		set_process(false)
		return
	_snap_turret_to_tile(turret, tile_pos)
	turret.can_shoot = true
	turret.can_be_shot = true
	Global.is_aiming = true
	turret.enable_sight_lines()


func _get_tile_pos_at_mouse() -> Vector2:
	var mouse_pos := level.get_local_mouse_position()
	return level.world_to_map(mouse_pos)


func _snap_turret_to_tile(turret: Turret, tile_pos: Vector2) -> void:
	var world_pos := level.map_to_world(tile_pos)  # Top left of tile
	var world_pos_centered := world_pos + level.cell_size / 2
	turret.global_position = world_pos_centered


func _is_top_overlapping_turret(turret: Turret) -> bool:
	var pos_in_parent := turret.get_position_in_parent()
	for child in placed_turrets.get_children():
		if (
			child.position == turret.position
			and child != turret
			and pos_in_parent < child.get_position_in_parent()
		):
			return false
	return true


func _on_item_button_down(_item: Item) -> void:
	var turret: Turret = TURRET_SCENE.instance()
	turret.bullets_node = bullets
# warning-ignore:return_value_discarded
	turret.connect("mouse_down", self, "_on_Turret_mouse_down", [turret])
# warning-ignore:return_value_discarded
	turret.connect("state_changed", self, "_on_turret_state_changed", [turret])
	placed_turrets.add_child(turret)
	_select_turret(turret)


func _on_item_button_up(_item: Item) -> void:
	if not Global.selected_turret:
		return
	_release_turret(Global.selected_turret)


func _on_Turret_mouse_down(turret: Turret) -> void:
	if Global.is_running or not _is_top_overlapping_turret(turret):
		return
	_select_turret(turret)


func _on_turret_state_changed(is_enabled: bool, turret: Turret) -> void:
	if not is_enabled and turret == Global.selected_turret:
		Global.selected_turret = null
		Global.is_aiming = false
		set_process(false)


func _on_StepDelay_timeout() -> void:
	for turret in placed_turrets.get_children():
		if turret.is_enabled:
			turret.shoot()
