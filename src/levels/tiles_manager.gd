class_name TilesManager
extends Object
# The class responsible for keeping track of every tile type.
# This class is used in editor scripts as well which do not support autoloaded
# singletons.

# warning-ignore-all:unused_class_variable

const LEVEL_EDITOR_TILE_SET := preload("res://levels/level_editor/level_editor_tileset.tres")
const MAIN_TILE_SET := preload("res://levels/tileset.tres")

const MAX_PATH_ORDER := 5

var LevelEditor := {
	"GROUND": LEVEL_EDITOR_TILE_SET.find_tile_by_name("ground"),
	"WALL": LEVEL_EDITOR_TILE_SET.find_tile_by_name("wall"),
	"ENEMY_PATH": LEVEL_EDITOR_TILE_SET.find_tile_by_name("enemy_path"),
}

var Main := {
	"GROUND": MAIN_TILE_SET.find_tile_by_name("ground"),
	"WALL": MAIN_TILE_SET.find_tile_by_name("wall"),
	"ENEMY_PATH": MAIN_TILE_SET.find_tile_by_name("enemy_path"),
	"BASE": MAIN_TILE_SET.find_tile_by_name("base"),
}

var level_editor_to_main := {
	LevelEditor.GROUND: Main.GROUND,
	LevelEditor.WALL: Main.WALL,
	LevelEditor.ENEMY_PATH: Main.ENEMY_PATH,
}

var enemy_path_start_tiles := []
var enemy_path_end_tiles := []
var enemy_path_tiles := [LevelEditor.ENEMY_PATH]


func _init() -> void:
	for i in range(1, MAX_PATH_ORDER + 1):
		var start_tile := LEVEL_EDITOR_TILE_SET.find_tile_by_name("enemy_path_start_%s" % i)
		var end_tile := LEVEL_EDITOR_TILE_SET.find_tile_by_name("enemy_path_end_%s" % i)
		LevelEditor["ENEMY_PATH_START_%s" % i] = start_tile
		LevelEditor["ENEMY_PATH_END_%s" % i] = end_tile
		level_editor_to_main[start_tile] = Main.ENEMY_PATH
		level_editor_to_main[end_tile] = Main.BASE
		enemy_path_start_tiles.append(start_tile)
		enemy_path_end_tiles.append(end_tile)
		enemy_path_tiles.append(start_tile)
		enemy_path_tiles.append(end_tile)

	for tile in LevelEditor:
		if LevelEditor[tile] == -1:
			push_warning("The LevelEditor.%s tile was not found!" % tile)
	for tile in Main:
		if Main[tile] == -1:
			push_warning("The Main.%s tile was not found!" % tile)
