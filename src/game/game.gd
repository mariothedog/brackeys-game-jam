extends Node2D

const TURRET_SCENE := preload("res://turret/turret.tscn")

const TURRET_AIMING_SNAP_DEG := 45

var _currently_aiming_item: TextureButton

onready var tilemap: TileMap = $TileMap
onready var tile_set: TileSet = tilemap.tile_set
onready var draggable_turrets: Node = $DraggableTurrets
onready var turrets: Node = $Turrets
onready var hud: CanvasLayer = $HUD

onready var Tiles := {"GROUND": tile_set.find_tile_by_name("ground")}


func _process(_delta: float) -> void:
	if _currently_aiming_item:
		var mouse_pos := get_global_mouse_position()
		var angle_to_mouse: float = (mouse_pos - _currently_aiming_item.gun.global_position).angle()
		var angle_snapped := stepify(angle_to_mouse, deg2rad(TURRET_AIMING_SNAP_DEG))
		_currently_aiming_item.gun.rotation = angle_snapped


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == BUTTON_LEFT
		and event.is_pressed()
		and _currently_aiming_item
	):
		_currently_aiming_item = null


func place_turret(pos: Vector2, rotation: float) -> void:
	var turret := TURRET_SCENE.instance()
	turret.global_position = pos
	turrets.add_child(turret)
	turret.gun.rotation = rotation


func _on_HUD_item_dropped(item: TextureButton, global_position: Vector2) -> void:
	var tile_pos := tilemap.world_to_map(global_position)
	if tilemap.get_cellv(tile_pos) != Tiles.GROUND:
		if item.get_parent() == draggable_turrets:
			Util.reparent(item, hud.inventory.items)
		item.rect_position = item.original_position
		item.gun.rotation = 0
		return
	var global_pos_snapped = tilemap.map_to_world(tile_pos) + tilemap.cell_size / 2
	Util.reparent(item, draggable_turrets)
	item.rect_global_position = global_pos_snapped - item.base.position
	_currently_aiming_item = item


func _on_HUD_start_pressed() -> void:
	for turret in draggable_turrets.get_children():
		var pos: Vector2 = turret.rect_global_position + turret.base.position
		place_turret(pos, turret.gun.rotation)
		turret.queue_free()
	hud.hide()
