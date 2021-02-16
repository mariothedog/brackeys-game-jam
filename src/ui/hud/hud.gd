extends CanvasLayer

signal item_draggable_button_down(draggable)
signal item_draggable_button_up(draggable)
signal start_pressed

onready var margin: MarginContainer = $MarginContainer
onready var inventory: MarginContainer = $MarginContainer/Inventory
onready var start: Button = $MarginContainer/Start


func show() -> void:
	margin.visible = true


func hide() -> void:
	margin.visible = false


func _on_Inventory_item_draggable_button_down(draggable: TextureButton) -> void:
	emit_signal("item_draggable_button_down", draggable)


func _on_Inventory_item_draggable_button_up(draggable: TextureButton) -> void:
	emit_signal("item_draggable_button_up", draggable)


func _on_Start_pressed() -> void:
	emit_signal("start_pressed")
