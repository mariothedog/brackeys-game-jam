tool
extends TileMap

export var create_level := false setget _create_level
export var clear_level := false setget _clear_level


func _create_level(_value) -> void:
	if not Engine.editor_hint:
		push_warning("Attempting to create a level resource when not in the editor")
		return

	var all_tiles := {}
	for type in tile_set.get_tiles_ids():
		var tiles := PoolVector2Array()
		for pos in get_used_cells_by_id(type):
			tiles.append(pos)
		all_tiles[type] = tiles
	
	var data := LevelData.new()
	data.tiles = all_tiles
	print(data)
	ResourceSaver.save("res://levels/resources//level_debug.tres", data)


func _clear_level(_value) -> void:
	clear()
