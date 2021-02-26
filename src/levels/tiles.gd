extends Node

const LEVEL_EDITOR_TILE_SET = preload("res://levels/level_editor/level_editor_tileset.tres")
const MAIN_TILE_SET = preload("res://levels/tileset.tres")

var LevelEditor := {
	"GROUND": LEVEL_EDITOR_TILE_SET.find_tile_by_name("ground"),
	"WALL": LEVEL_EDITOR_TILE_SET.find_tile_by_name("wall"),
	"ENEMY_PATH": LEVEL_EDITOR_TILE_SET.find_tile_by_name("enemy_path"),
	"ENEMY_PATH_START": LEVEL_EDITOR_TILE_SET.find_tile_by_name("enemy_path_start"),
	"ENEMY_PATH_END": LEVEL_EDITOR_TILE_SET.find_tile_by_name("enemy_path_end"),
}

var Main := {
	"GROUND": MAIN_TILE_SET.find_tile_by_name("ground"),
	"WALL": MAIN_TILE_SET.find_tile_by_name("wall"),
	"ENEMY_PATH": MAIN_TILE_SET.find_tile_by_name("enemy_path")
}

var level_editor_to_main := {
	LevelEditor.GROUND: Main.GROUND,
	LevelEditor.WALL: Main.WALL,
	LevelEditor.ENEMY_PATH: Main.ENEMY_PATH,
	LevelEditor.ENEMY_PATH_START: Main.ENEMY_PATH,
	LevelEditor.ENEMY_PATH_END: Main.ENEMY_PATH,
}
