extends CanvasLayer

signal item_dropped(item, position)
signal start_pressed


func _on_Inventory_item_dropped(item, global_position) -> void:
	emit_signal("item_dropped", item, global_position)


func _on_Start_pressed() -> void:
	emit_signal("start_pressed")
