extends Control

export var inv_pixels_visible_def := 1
export var inv_slide_dur := 1.0

onready var tween: Tween = $Tween
onready var inventory: MarginContainer = $Inventory

# Export variables get set after initialization so this must be onready
onready var _inv_start_pos_x := Constants.WINDOW_WIDTH - inv_pixels_visible_def
onready var _inv_end_pos_x := inventory.rect_position.x


func _ready() -> void:
	inventory.rect_position.x = _inv_start_pos_x
# warning-ignore:return_value_discarded
	Signals.connect("item_button_down", self, "_on_item_button_down")


func slide_inventory_out() -> void:
	# warning-ignore:return_value_discarded
	tween.interpolate_property(
		inventory,
		"rect_position:x",
		inventory.rect_position.x,
		_inv_end_pos_x,
		inv_slide_dur,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
# warning-ignore:return_value_discarded
	tween.start()


func slide_inventory_in() -> void:
	# warning-ignore:return_value_discarded
	tween.interpolate_property(
		inventory,
		"rect_position:x",
		inventory.rect_position.x,
		_inv_start_pos_x,
		inv_slide_dur,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
# warning-ignore:return_value_discarded
	tween.start()


func _on_Inventory_mouse_entered_background() -> void:
	if Global.selected_turret and not Global.is_aiming:
		return
	slide_inventory_out()


func _on_Inventory_mouse_exited_background() -> void:
	if Global.selected_turret and not Global.is_aiming:
		return
	slide_inventory_in()


func _on_item_button_down(_item: Item) -> void:
	slide_inventory_in()
