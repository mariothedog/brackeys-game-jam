extends TileMap


func build_level(level_data: LevelData) -> void:
	for type in level_data.tiles:
		var tiles: PoolVector2Array = level_data.tiles[type]
		for pos in tiles:
			set_cellv(pos, type)
