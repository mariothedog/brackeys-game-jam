extends TileMap


onready var Tiles := {
	"GROUND": tile_set.find_tile_by_name("ground"),
	"WALL": tile_set.find_tile_by_name("wall"),
	"ENEMY_PATH": tile_set.find_tile_by_name("enemy_path")
}


func _ready() -> void:
	for tile in Tiles:
		if Tiles[tile] == -1:
			push_error("The %s tile was not found!" % tile)
