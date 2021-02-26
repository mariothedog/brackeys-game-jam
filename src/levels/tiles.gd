extends Node

const LEVEL_EDITOR_TILE_SET = preload("res://levels/level_editor/level_editor_tileset.tres")
const MAIN_TILE_SET = preload("res://levels/tileset.tres")

var LevelEditor := {
	"GROUND": LEVEL_EDITOR_TILE_SET.find_tile_by_name("ground"),
	"WALL": LEVEL_EDITOR_TILE_SET.find_tile_by_name("wall"),
}

var Main := {
	"GROUND": MAIN_TILE_SET.find_tile_by_name("ground"),
	"WALL": MAIN_TILE_SET.find_tile_by_name("wall"),
}

var level_editor_to_main := {
	LevelEditor.GROUND: Main.GROUND,
	LevelEditor.WALL: Main.WALL,
}
