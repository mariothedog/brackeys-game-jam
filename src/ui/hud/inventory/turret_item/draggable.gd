extends TextureButton

onready var gun: Sprite = $Gun
onready var base: Position2D = $Base

var turret_item: TextureRect

var default_rect_global_position: Vector2
var num_overlapping_turrets := 1 setget _set_num_overlapping_turrets


func reset() -> void:
	rect_global_position = default_rect_global_position
	gun.rotation = 0
	turret_item.visible = true


func _set_num_overlapping_turrets(value) -> void:
	num_overlapping_turrets = value
	gun.scale = Vector2.ONE * num_overlapping_turrets
