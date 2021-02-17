extends TextureButton

onready var gun: Sprite = $Gun
onready var base: Position2D = $Base
onready var sight_lines: Node2D = $Gun/SightLines
onready var sight_blocker_collider: CollisionShape2D = $SightBlocker/CollisionShape2D

var turret_item: TextureRect

var default_global_pos: Vector2
var level := 1 setget _set_level


func reset() -> void:
	rect_global_position = default_global_pos
	gun.rotation = 0


func enable_sight_lines() -> void:
	for sight_line in sight_lines.get_children():
		if sight_line.visible:
			sight_line.is_casting = true


func disable_sight_lines() -> void:
	for sight_line in sight_lines.get_children():
		if sight_line.visible:
			sight_line.is_casting = false


func update_sight_line() -> void:
	for sight_line in sight_lines.get_children():
		if sight_line.visible:
			sight_line.update()


func enable_sight_blocker() -> void:
	sight_blocker_collider.set_deferred("disabled", false)


func disable_sight_blocker() -> void:
	sight_blocker_collider.set_deferred("disabled", true)


func _set_level(value) -> void:
	if value == 0 or level == value:
		level = value
		return
	elif value > gun.hframes:
		level = value
		push_error("Turret level is greater than the number of gun frames available")
		return
	level = value
	gun.frame = level - 1

	for i in sight_lines.get_child_count():
		var sight_line := sight_lines.get_child(i)
		sight_line.visible = i < level
