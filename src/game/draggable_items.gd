extends Node2D

signal draggable_turret_button_down(turret)
signal draggable_turret_button_up(turret)

const DRAGGABLE_TURRET_SCENE := preload("res://draggable_turret/draggable_turret.tscn")
const PADDING := Vector2(4, 4)
const SPACING := Vector2(0, 14)

export var num_turrets := 1

onready var draggable_turrets = $DraggableTurrets


func _ready() -> void:
	for i in num_turrets:
		var turret := DRAGGABLE_TURRET_SCENE.instance()
		var pos: Vector2 = PADDING + SPACING * i
		turret.default_global_pos = to_global(pos)
		turret.rect_position = pos
		assert(turret.connect("button_down", self, "_on_draggable_turret_button_down", [turret]) == OK)
		assert(turret.connect("button_up", self, "_on_draggable_turret_button_up", [turret]) == OK)
		assert(turret.connect("reset", self, "_on_draggable_turret_reset") == OK)
		draggable_turrets.add_child(turret)


func _update_inventory() -> void:
	var i := 0
	for turret in draggable_turrets.get_children():
		if turret.is_in_group("placed_draggable_turrets"):
			continue
		var pos: Vector2 = PADDING + SPACING * i
		turret.default_global_pos = to_global(pos)
		turret.rect_position = pos
		i += 1


func _on_draggable_turret_button_down(turret: TextureButton) -> void:
	_update_inventory()
	emit_signal("draggable_turret_button_down", turret)


func _on_draggable_turret_button_up(turret: TextureButton) -> void:
	_update_inventory()
	emit_signal("draggable_turret_button_up", turret)


func _on_draggable_turret_reset() -> void:
	_update_inventory()
