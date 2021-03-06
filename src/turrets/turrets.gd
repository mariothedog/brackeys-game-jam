extends Node2D

signal turret_added(turret)

const TURRET_SCENE = preload("res://turrets/turret.tscn")

const TURRET_AIMING_ANGLE_SNAP := deg2rad(45)

export (NodePath) var level_path

var Tiles := TilesManager.new()

var _selected_turret: Turret
var _is_aiming := false

onready var level: TileMap = get_node(level_path)


func _ready() -> void:
	set_process(false)
# warning-ignore:return_value_discarded
	Signals.connect("item_button_down", self, "_on_item_button_down")
# warning-ignore:return_value_discarded
	Signals.connect("item_button_up", self, "_on_item_button_up")
# warning-ignore:return_value_discarded
	Signals.connect("draggable_turret_button_down", self, "_on_draggable_turret_button_down")
# warning-ignore:return_value_discarded
	Signals.connect("draggable_turret_button_up", self, "_on_draggable_turret_button_up")


func _process(_delta: float) -> void:
	if _is_aiming:
		var mouse_pos := _selected_turret.get_local_mouse_position()
		var angle_to_mouse := mouse_pos.angle()
		var angle_snapped := stepify(angle_to_mouse, TURRET_AIMING_ANGLE_SNAP)
		_selected_turret.rotate_gun_to(angle_snapped)
	else:
		_selected_turret.position = get_local_mouse_position()


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == BUTTON_LEFT
		and event.is_pressed()
		and _is_aiming
	):
		set_process(false)
		_selected_turret = null
		_is_aiming = false


func _select_turret(turret: Turret) -> void:
	turret.z_index = 2
	turret.can_shoot = false
	_selected_turret = turret
	set_process(true)


func _release_turret(turret: Turret) -> void:
	var tile_pos := _get_tile_pos_at_mouse()
	if level.get_cellv(tile_pos) != Tiles.Main.GROUND:
		turret.queue_free()
		set_process(false)
		return
	_snap_turret_to_tile(turret, tile_pos)
	turret.z_index = 0
	turret.can_shoot = true
	_is_aiming = true


func _get_tile_pos_at_mouse() -> Vector2:
	var mouse_pos := level.get_local_mouse_position()
	return level.world_to_map(mouse_pos)


func _snap_turret_to_tile(turret: Turret, tile_pos: Vector2) -> void:
	var world_pos := level.map_to_world(tile_pos)  # Top left of tile
	var world_pos_centered := world_pos + level.cell_size / 2
	turret.global_position = world_pos_centered


func _is_top_overlapping_turret(turret: Turret) -> bool:
	var pos_in_parent := turret.get_position_in_parent()
	for child in get_children():
		if (
			child.position == turret.position
			and child != turret
			and pos_in_parent < child.get_position_in_parent()
		):
			return false
	return true


func _on_item_button_down(_item: Item) -> void:
	var turret: Turret = TURRET_SCENE.instance()
	add_child(turret)
	emit_signal("turret_added", turret)
	_select_turret(turret)


func _on_item_button_up(_item: Item) -> void:
	_release_turret(_selected_turret)


func _on_draggable_turret_button_down(turret: Turret) -> void:
	if not _is_top_overlapping_turret(turret):
		return
	_select_turret(turret)
	set_process(true)


func _on_draggable_turret_button_up(turret: Turret) -> void:
	_release_turret(turret)
