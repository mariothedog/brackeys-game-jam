extends MarginContainer

signal mouse_entered_background
signal mouse_exited_background

var _prev_is_mouse_inside := false


func _ready() -> void:
	# Related issue: https://github.com/godotengine/godot/issues/46915
	rect_min_size.x = rect_size.x


func _process(_delta: float) -> void:
	# The mouse_entered/mouse_exited signals are not enough
	# Related issue: https://github.com/godotengine/godot/issues/16854
	var is_mouse_inside := _is_mouse_inside()
	if not _is_mouse_inside_viewport():
		return
	if is_mouse_inside and not _prev_is_mouse_inside:
		emit_signal("mouse_entered_background")
	elif not is_mouse_inside and _prev_is_mouse_inside:
		emit_signal("mouse_exited_background")
	_prev_is_mouse_inside = is_mouse_inside


func _is_mouse_inside() -> bool:
	return get_global_rect().has_point(get_global_mouse_position())


func _is_mouse_inside_viewport() -> bool:
	return get_viewport_rect().has_point(get_global_mouse_position())
