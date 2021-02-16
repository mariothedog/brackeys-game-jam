extends Node2D

const TURRET_SCENE := preload("res://turret/turret.tscn")

const TURRET_AIMING_SNAP_DEG := 45

var _selected_draggable_item: TextureButton
var _drag_offset: Vector2
var _currently_aiming_draggable_item: TextureButton

onready var tilemap: TileMap = $TileMap
onready var tile_set: TileSet = tilemap.tile_set
onready var bullets: Node = $Bullets
onready var turrets: Node = $Turrets
onready var hud: CanvasLayer = $HUD

onready var Tiles := {
	"GROUND": tile_set.find_tile_by_name("ground"),
	"WALL": tile_set.find_tile_by_name("wall")
}


func _ready() -> void:
	for tile in Tiles:
		if Tiles[tile] == -1:
			push_error("The %s tile was not found!" % tile)


func _process(_delta: float) -> void:
	if _selected_draggable_item:
		var pos := get_global_mouse_position() + _drag_offset
		_selected_draggable_item.rect_global_position = pos
	elif _currently_aiming_draggable_item:
		var gun_pos: Vector2 = _currently_aiming_draggable_item.gun.global_position
		var mouse_pos := get_global_mouse_position()
		var angle_to_mouse: float = (mouse_pos - gun_pos).angle()
		var angle_snapped := stepify(angle_to_mouse, deg2rad(TURRET_AIMING_SNAP_DEG))
		_currently_aiming_draggable_item.gun.rotation = angle_snapped
		_currently_aiming_draggable_item.sight_line.update()


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == BUTTON_LEFT
		and event.is_pressed()
		and _currently_aiming_draggable_item
	):
		_currently_aiming_draggable_item.sight_line.is_casting = false
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
	for item in get_tree().get_nodes_in_group("placed_draggable_items"):
		if item.draggable.global_position == global_pos:
			items.append(item)
	return items


func _update_draggable_items() -> void:
	var draggable_items_at_pos := {}
	for draggable_item in get_tree().get_nodes_in_group("placed_draggable_items"):
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
			item.num_overlapping_turrets = num
			item.visible = i == num - 1


func _on_HUD_item_draggable_button_down(draggable: TextureButton) -> void:
	draggable.raise()
	draggable.turret_item.visible = false

	_drag_offset = -draggable.base.position
	_selected_draggable_item = draggable
	if _selected_draggable_item.is_in_group("placed_draggable_items"):
		_selected_draggable_item.remove_from_group("placed_draggable_items")
	_update_draggable_items()
	_selected_draggable_item.num_overlapping_turrets = 1


func _on_HUD_item_draggable_button_up(draggable: TextureButton) -> void:
	_selected_draggable_item = null

	var tile_pos := tilemap.world_to_map(get_global_mouse_position())
	if tilemap.get_cellv(tile_pos) != Tiles.GROUND:
		draggable.reset()
		return

	var global_pos_snapped = (
		tilemap.map_to_world(tile_pos)
		+ tilemap.cell_size / 2
		- draggable.base.position
	)

	draggable.rect_global_position = global_pos_snapped
	draggable.add_to_group("placed_draggable_items")

	_currently_aiming_draggable_item = draggable
	draggable.sight_line.is_casting = true

	_update_draggable_items()


func _on_HUD_start_pressed() -> void:
	hud.hide()
	for item in get_tree().get_nodes_in_group("placed_draggable_items"):
		if not item.visible:
			continue
		var pos: Vector2 = item.rect_global_position + item.base.position
		_place_turret(pos, item.gun.rotation, item.num_overlapping_turrets)
		item.reset()


func _on_bullet_spawned(bullet: Area2D) -> void:
	bullets.add_child(bullet)
