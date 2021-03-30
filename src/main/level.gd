class_name Level
extends TileMap

const ENEMY_SPAWN_INDICATOR_SCENE = preload("res://enemies/enemy_spawn_indicator.tscn")

var Tiles := TilesManager.new()

onready var enemies: Enemies = $Enemies
onready var enemy_spawn_indicators: Node = $EnemySpawnIndicators


func build_level(level_data: LevelData) -> void:
	clear()
	for type in level_data.tiles:
		var tiles: PoolVector2Array = level_data.tiles[type]
		for pos in tiles:
			if Tiles.level_editor_to_main.has(type):
				set_cellv(pos, Tiles.level_editor_to_main[type])
			else:
				push_warning("Level editor tile %s has no corresponding main tile" % type)

	var world_paths := []
	for path in level_data.enemy_paths:
		var world_path := Util.map(funcref(self, "_point_to_world"), path)
		world_paths.append(world_path)

	enemies.paths = world_paths
	_add_enemy_spawn_indicators(world_paths)


func _point_to_world(point: Vector2) -> Vector2:
	return map_to_world(point) + cell_size / 2


func start() -> void:
	for spawn_indicator in enemy_spawn_indicators.get_children():
		spawn_indicator.visible = false


func stop() -> void:
	enemies.path_index = 0
	for spawn_indicator in enemy_spawn_indicators.get_children():
		spawn_indicator.visible = true


func _add_enemy_spawn_indicators(paths: Array) -> void:
	for path in paths:
		var start_pos: Vector2 = path[0]
		var spawn_indicator = ENEMY_SPAWN_INDICATOR_SCENE.instance()
		spawn_indicator.global_position = start_pos
		enemy_spawn_indicators.add_child(spawn_indicator)
