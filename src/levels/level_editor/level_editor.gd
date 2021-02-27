tool
extends TileMap

export var create_level := false setget _create_level
export var clear_level := false setget _clear_level

var astar: AStar
var level_size: Vector2
var enemy_path_start_points: PoolVector2Array
var enemy_path_end_points: PoolVector2Array
var enemy_path_points: PoolVector2Array


func _create_level(value: bool) -> void:
	if not value:
		# Return if setter is called automatically
		return
	if not Engine.editor_hint:
		push_warning("Attempting to create a level resource when not in the editor")
		return

	var Tiles := TilesManager.new()
	var enemy_path_tiles := [
		Tiles.LevelEditor.ENEMY_PATH_START,
		Tiles.LevelEditor.ENEMY_PATH_END,
		Tiles.LevelEditor.ENEMY_PATH,
	]

	astar = AStar.new()
	var used_rect := get_used_rect()
	level_size = used_rect.position + used_rect.size
	enemy_path_start_points = PoolVector2Array()
	enemy_path_end_points = PoolVector2Array()
	enemy_path_points = PoolVector2Array()

	var all_tiles := {}
	for type in tile_set.get_tiles_ids():
		var tiles := PoolVector2Array()
		for point in get_used_cells_by_id(type):
			tiles.append(point)

			if not type in enemy_path_tiles:
				continue
			var point_index := get_point_index(point)
			astar.add_point(point_index, Util.get_Vector3(point))
			enemy_path_points.append(point)
			match type:
				Tiles.LevelEditor.ENEMY_PATH_START:
					enemy_path_start_points.append(point)
				Tiles.LevelEditor.ENEMY_PATH_END:
					enemy_path_end_points.append(point)

		if tiles:
			all_tiles[type] = tiles

	connect_enemy_path_points(enemy_path_points)
	var paths := get_all_astar_paths(enemy_path_start_points, enemy_path_end_points)

	var data := LevelData.new()
	data.tiles = all_tiles
	data.enemy_paths = paths
# warning-ignore:return_value_discarded
	ResourceSaver.save("res://levels/resources//level_debug.tres", data)


func _clear_level(value: bool) -> void:
	if not value:
		# Return if setter is called automatically
		return
	clear()


func get_all_astar_paths(start_points: PoolVector2Array, end_points: PoolVector2Array) -> Array:
	var paths := []
	for start_point in start_points:
		for end_point in end_points:
			var path := get_astar_path(start_point, end_point)
			if path:
				paths.append(path)
	return paths


func get_astar_path(start_point: Vector2, end_point: Vector2) -> PoolVector2Array:
	var start_point_index := get_point_index(start_point)
	var end_point_index := get_point_index(end_point)
	var path := astar.get_point_path(start_point_index, end_point_index)
	return Util.get_PoolVector2Array(path)


func connect_enemy_path_points(points: PoolVector2Array) -> void:
	for point in points:
		var point_index := get_point_index(point)
		var points_relative := PoolVector2Array(
			[
				point + Vector2.RIGHT,
				point + Vector2.LEFT,
				point + Vector2.DOWN,
				point + Vector2.UP,
			]
		)
		for point_relative in points_relative:
			var point_relative_index = get_point_index(point_relative)
			if not astar.has_point(point_relative_index):
				continue
			astar.connect_points(point_index, point_relative_index, false)
			update()


func get_point_index(point: Vector2) -> int:
	return int(point.x * level_size.x + point.y)
