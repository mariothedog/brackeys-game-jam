class_name HUD
extends Control

const STEP_LABEL_SCENE := preload("res://ui/hud/steps/step_label.tscn")

export var inv_pixels_visible_def := 1
export var inv_slide_dur := 1.0

var _is_mouse_in_background := false

onready var tween: Tween = $Tween
onready var inventory: MarginContainer = $Inventory
onready var step_labels: VBoxContainer = $StepLabelsMargin/StepLabels

# Export variables get set after initialization so this must be onready
onready var _inv_start_pos_x := Constants.WINDOW_WIDTH - inv_pixels_visible_def
onready var _inv_end_pos_x := inventory.rect_position.x


func _ready() -> void:
	inventory.rect_position.x = _inv_start_pos_x


func add_step_labels(step_types: Dictionary, steps: Array) -> void:
	var step_names := step_types.keys()
	for step in steps:
		var step_name: String = step_names[step].to_lower()
		var label: Label = STEP_LABEL_SCENE.instance()
		label.text = step_name
		step_labels.add_child(label)


func highlight_step_labels(highlight_index: int) -> void:  # An invalid highlight_index will highlight nothing
	for i in step_labels.get_child_count():
		var label: Label = step_labels.get_child(i)
		if i == highlight_index:
			label.add_color_override("font_color", Color.black)
		else:
			label.add_color_override("font_color", Color.white)


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


func _on_Inventory_mouse_entered_background() -> void:
	_is_mouse_in_background = true
	if (Global.selected_turret and not Global.is_aiming) or Global.is_running:
		return
	slide_inventory_out()


func _on_Inventory_mouse_exited_background() -> void:
	_is_mouse_in_background = false
	slide_inventory_in()
