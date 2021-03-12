extends TileMap

var Tiles := TilesManager.new()
var data: LevelData

onready var enemies: Enemies = $Enemies


func build_level(level_data: LevelData) -> void:
	data = level_data
	for type in data.tiles:
		var tiles: PoolVector2Array = data.tiles[type]
		for pos in tiles:
			if Tiles.level_editor_to_main.has(type):
				set_cellv(pos, Tiles.level_editor_to_main[type])
			else:
				push_warning("Level editor tile %s has no corresponding main tile" % type)

	var world_paths := []
	for path in data.enemy_paths:
		var world_path := Util.map(funcref(self, "point_to_world"), path)
		world_paths.append(world_path)
		var line2d := Line2D.new()
		line2d.width = 1
		line2d.default_color = rand_color(0.5)
		line2d.points = world_path
		add_child(line2d)

	enemies.paths = world_paths


func point_to_world(point: Vector2) -> Vector2:
	return map_to_world(point) + cell_size / 2


func rand_color(alpha: float) -> Color:
	return Color(randf(), randf(), randf(), alpha)
