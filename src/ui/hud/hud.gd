class_name HUD
extends Control

export var inv_pixels_visible_def := 1
export var inv_slide_dur := 1.0

var _is_mouse_in_background := false

onready var tween: Tween = $Tween
onready var inventory: MarginContainer = $Inventory

# Export variables get set after initialization so this must be onready
onready var _inv_start_pos_x := Constants.WINDOW_WIDTH - inv_pixels_visible_def
onready var _inv_end_pos_x := inventory.rect_position.x


func _ready() -> void:
	inventory.rect_position.x = _inv_start_pos_x


func slide_inventory_out() -> void:
	if is_equal_approx(inventory.rect_position.x, _inv_end_pos_x):
		return
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
	if is_equal_approx(inventory.rect_position.x, _inv_start_pos_x):
		return
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


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and (event as InputEventMouseButton).button_index == BUTTON_LEFT
		and event.is_pressed()
	):
		slide_inventory_in()


func _on_Inventory_mouse_entered_background() -> void:
	_is_mouse_in_background = true
	if (Global.selected_turret and not Global.is_aiming) or Global.is_running:
		return
	slide_inventory_out()


func _on_Inventory_mouse_exited_background() -> void:
	_is_mouse_in_background = false
	if (Global.selected_turret and not Global.is_aiming) or Global.is_running:
		return
	slide_inventory_in()
