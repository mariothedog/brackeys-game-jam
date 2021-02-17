extends Node2D

const TURRET_SCENE := preload("res://turret/turret.tscn")

const TURRET_AIMING_SNAP_DEG := 45

var _selected_draggable_item: TextureButton
var _drag_offset: Vector2
var _currently_aiming_draggable_item: TextureButton

onready var tilemap: TileMap = $TileMap
onready var tile_set: TileSet = tilemap.tile_set
onready var bullets: Node = $Bullets
onready var turrets: Node2D = $Turrets
onready var inventory: Node2D = $Inventory
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


func _on_Inventory_draggable_turret_button_down(turret: TextureButton) -> void:
	turret.raise()
#	turret.turret_item.visible = false
	turret.disable_sight_lines()

	_drag_offset = -turret.base.position
	_selected_draggable_item = turret
	if _selected_draggable_item.is_in_group("placed_draggable_turrets"):
		_selected_draggable_item.remove_from_group("placed_draggable_turrets")
		turret.disable_sight_blocker()
	_update_draggable_items()
	_selected_draggable_item.level = 1
	get_tree().call_group("placed_draggable_turrets", "update_sight_line")


func _on_Inventory_draggable_turret_button_up(turret: TextureButton) -> void:
	_selected_draggable_item = null

	var tile_pos := tilemap.world_to_map(get_global_mouse_position())
	if tilemap.get_cellv(tile_pos) != Tiles.GROUND:
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
	hud.hide()
	inventory.visible = false
	for item in get_tree().get_nodes_in_group("placed_draggable_turrets"):
		if not item.visible:
			item.reset()
			continue
		var pos: Vector2 = item.rect_global_position + item.base.position
		_place_turret(pos, item.gun.rotation, item.level)
		item.reset()


func _on_bullet_spawned(bullet: Area2D) -> void:
	bullets.add_child(bullet)
