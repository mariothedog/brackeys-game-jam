class_name Item
extends HBoxContainer

var num_left := 1 setget _set_num_left

onready var number_label: Label = $Number


func _set_num_left(value: int) -> void:
	num_left = value
	number_label.text = str(num_left)


func _on_TextureRect_button_down() -> void:
	if num_left > 0:
		Signals.emit_signal("item_button_down", self)
