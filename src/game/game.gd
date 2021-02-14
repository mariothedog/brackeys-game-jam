extends Node

const TURRET_SCENE := preload("res://turret/turret.tscn")

onready var tilemap: TileMap = $TileMap
onready var tile_set: TileSet = tilemap.tile_set
onready var turrets: Node = $Turrets

onready var Tiles := {
	"GROUND": tile_set.find_tile_by_name("ground")
}


func _on_Inventory_item_dropped(item: TextureButton, global_position: Vector2) -> void:
	var tile_pos := tilemap.world_to_map(global_position)
	if tilemap.get_cellv(tile_pos) != Tiles.GROUND:
		return
	
	var global_pos_snapped = tilemap.map_to_world(tile_pos) + tilemap.cell_size/2
	var turret := TURRET_SCENE.instance()
	turret.global_position = global_pos_snapped
	turrets.add_child(turret)
