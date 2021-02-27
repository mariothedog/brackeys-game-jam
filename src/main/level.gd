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

	for path in level_data.enemy_paths:
		var world_path := Util.map(funcref(self, "point_to_world"), path)
		var line2d = Line2D.new()
		line2d.width = 1
		line2d.default_color = rand_color()
		line2d.points = world_path
		add_child(line2d)


func point_to_world(point: Vector2) -> Vector2:
	return map_to_world(point) + cell_size / 2


func rand_color() -> Color:
	return Color(randf(), randf(), randf())
