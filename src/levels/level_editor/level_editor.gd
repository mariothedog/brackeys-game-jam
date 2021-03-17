tool
extends TileMap

const FORMAT_PATH := "res://levels/resources//level_%s.tres"

export var level_name := "debug"
export (int, 1, 100) var num_lives := 1
export (int, 1, 100) var num_turrets := 1
export (int, 0, 1000) var num_enemies := 1
# warning-ignore:unused_class_variable
export var create_level := false setget _create_level
# warning-ignore:unused_class_variable
export var clear_level := false setget _clear_level

var Tiles: TilesManager

var astar: AStar
var level_size: Vector2
var enemy_path_start_points: PoolVector2Array
var enemy_path_end_points: PoolVector2Array
var enemy_path_points: PoolVector2Array


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


func _create_level(value: bool) -> void:
	if not value:
		# Return if setter is called automatically
		return
	if not Engine.editor_hint:
		push_warning("Attempting to create a level resource when not in the editor")
		return

	Tiles = TilesManager.new()
	astar = AStar.new()
	var used_rect := get_used_rect()
	level_size = used_rect.position + used_rect.size
	enemy_path_start_points = PoolVector2Array()
	enemy_path_end_points = PoolVector2Array()
	enemy_path_points = PoolVector2Array()

	var all_tiles := {}
	var tile_ids := tile_set.get_tiles_ids()
	tile_ids.sort_custom(self, "_sort_tile_ids")
	for type in tile_ids:
		var tiles := PoolVector2Array()
		for point in get_used_cells_by_id(type):
			tiles.append(point)

			if not type in Tiles.enemy_path_tiles:
				continue
			var point_index := get_point_index(point)
			astar.add_point(point_index, Util.get_Vector3(point))
			enemy_path_points.append(point)
			if type in Tiles.enemy_path_start_tiles:
				enemy_path_start_points.append(point)
			elif type in Tiles.enemy_path_end_tiles:
				enemy_path_end_points.append(point)
		if tiles:
			all_tiles[type] = tiles

	connect_enemy_path_points(enemy_path_points)
	var paths := get_all_astar_paths(enemy_path_start_points, enemy_path_end_points)

	var data := LevelData.new()
	data.tiles = all_tiles
	data.enemy_paths = paths
	data.num_lives = num_lives
	data.num_turrets = num_turrets
	data.num_enemies = num_enemies
# warning-ignore:return_value_discarded
	ResourceSaver.save(FORMAT_PATH % level_name, data)


func _sort_tile_ids(a, b):
	# Order:
	# - Start paths
	# - End paths
	# - Other tiles (including normal paths)
	var a_start_index := Tiles.enemy_path_start_tiles.find(a)
	var b_start_index := Tiles.enemy_path_start_tiles.find(b)
	var a_end_index := Tiles.enemy_path_end_tiles.find(a)
	var b_end_index := Tiles.enemy_path_end_tiles.find(b)
	if a_start_index > -1 and b_start_index > -1:
		return a_start_index < b_start_index
	elif a_end_index > -1 and b_end_index > -1:
		return a_end_index < b_end_index
	elif a_start_index > -1:
		return true
	elif b_start_index > -1:
		return false
	elif a_end_index > -1:
		return true
	elif b_end_index > -1:
		return false
	return a < b


func _clear_level(value: bool) -> void:
	if not value:
		# Return if setter is called automatically
		return
	clear()
