class_name Item
extends HBoxContainer


func _on_TextureRect_button_down() -> void:
	Signals.emit_signal("item_button_down", self)
