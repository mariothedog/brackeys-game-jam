extends MarginContainer

signal item_draggable_button_down(draggable)
signal item_draggable_button_up(draggable)

const TURRET_ITEM_SCENE := preload("res://ui/hud/inventory/turret_item.tscn")
const DRAGGABLE_ITEM_SCENE := preload("res://ui/draggable_turret_item/draggable_turret_item.tscn")

export var num_turrets := 1

onready var turret_items: VBoxContainer = $MarginContainer/TurretItems
onready var draggable_items: Node2D = $DraggableItems


func _ready() -> void:
	for _i in num_turrets:
		var turret: TextureRect = TURRET_ITEM_SCENE.instance()
		turret_items.add_child(turret)

		var draggable := DRAGGABLE_ITEM_SCENE.instance()
		draggable.turret_item = turret
		assert(draggable.connect("button_down", self, "_on_item_draggable_button_down", [draggable]) == OK)
		assert(draggable.connect("button_up", self, "_on_item_draggable_button_up", [draggable]) == OK)
		draggable_items.add_child(draggable)


func _on_TurretItems_sort_children() -> void:
	for draggable in draggable_items.get_children():
		if draggable.is_in_group("placed_draggable_items"):
			continue
		draggable.default_rect_global_position = draggable.turret_item.rect_global_position
		draggable.rect_global_position = draggable.turret_item.rect_global_position


func _on_item_draggable_button_down(draggable: TextureButton) -> void:
	emit_signal("item_draggable_button_down", draggable)


func _on_item_draggable_button_up(draggable: TextureButton) -> void:
	emit_signal("item_draggable_button_up", draggable)
