class_name Turret
extends Area2D

const FULL_ROTATION := TAU
const ROTATION_THRESHOLD := deg2rad(1)
const ROTATION_WEIGHT := 0.4
var ROTATION_RATE: float = ROTATION_WEIGHT * Constants.PHYSICS_FPS

var is_draggable := true

var _target_rotation: float

onready var gun: Sprite = $Gun


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if abs(gun.rotation - _target_rotation) <= ROTATION_THRESHOLD:
		gun.rotation = _target_rotation
		set_physics_process(false)
		return
	var rot := lerp_angle(gun.rotation, _target_rotation, ROTATION_RATE * delta)
	# wrapf alone will restrict it to a positive range
	# However, the rotation may be slightly less than 360 degrees but still
	# close enough that it should be considered as 0 degrees
	rot = Util.wrapf_with_threshold(rot, 0, FULL_ROTATION, ROTATION_THRESHOLD)
	gun.rotation = rot


func rotate_gun_to(radians: float) -> void:
	radians = wrapf(radians, 0, FULL_ROTATION)  # Restrict to a positive range
	if is_equal_approx(gun.rotation, radians):
		return
	_target_rotation = radians
	set_physics_process(true)


func _on_Turret_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not event is InputEventMouseButton or event.button_index != BUTTON_LEFT or not is_draggable:
		return
	if event.is_pressed():
		Signals.emit_signal("draggable_turret_button_down", self)
	else:
		Signals.emit_signal("draggable_turret_button_up", self)
