extends TileMap

var Tiles := preload("res://levels/tiles.gd").new()


func build_level(level_data: LevelData) -> void:
	for type in level_data.tiles:
		var tiles: PoolVector2Array = level_data.tiles[type]
		for pos in tiles:
			if Tiles.level_editor_to_main.has(type):
				set_cellv(pos, Tiles.level_editor_to_main[type])
			else:
				push_warning("Level editor tile %s has no corresponding main tile" % type)
