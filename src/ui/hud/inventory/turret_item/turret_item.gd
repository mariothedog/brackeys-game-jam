extends TextureButton

var original_position: Vector2

var num_overlapping_turrets := 1 setget _set_num_overlapping_turrets

onready var base: Sprite = $Base
onready var gun: Sprite = $Gun


func _set_num_overlapping_turrets(value) -> void:
	num_overlapping_turrets = value
	gun.scale = Vector2.ONE * num_overlapping_turrets
