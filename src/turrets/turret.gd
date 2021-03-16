class_name Turret
extends Area2D

signal mouse_down

const LASER_SCENE := preload("res://turrets/laser/laser.tscn")
const BULLET_SCENE := preload("res://projectiles/bullet/bullet.tscn")

const GUN_ROTATIONS := [
	0,
	deg2rad(180),
	deg2rad(90),
	deg2rad(270),
	deg2rad(315),
	deg2rad(45),
	deg2rad(135),
	deg2rad(225),
]

const ROTATION_THRESHOLD := deg2rad(1)
const ROTATION_WEIGHT := 0.3
var ROTATION_RATE: float = ROTATION_WEIGHT * Constants.PHYSICS_FPS

var is_enabled := true
# Turret level 0 is reserved for merged turrets
var level := 1 setget _set_level

var _target_rotation: float

onready var gun: Sprite = $Gun
onready var lasers := $Gun/Lasers
onready var collider: CollisionShape2D = $CollisionShape2D
onready var laser_blocker_collider: CollisionShape2D = $LaserBlocker/CollisionShape2D


func _ready() -> void:
	set_physics_process(false)
	_instance_lasers()


func _physics_process(delta: float) -> void:
	if abs(gun.rotation - _target_rotation) <= ROTATION_THRESHOLD:
		gun.rotation = _target_rotation
		set_physics_process(false)
		return
	var rot := lerp_angle(gun.rotation, _target_rotation, ROTATION_RATE * delta)
	# wrapf alone will restrict it to a positive range
	# However, the rotation may be slightly less than 360 degrees but still
	# close enough that it should be considered as 0 degrees
	rot = Util.wrapf_with_threshold(rot, 0, Constants.FULL_ROTATION, ROTATION_THRESHOLD)
	gun.rotation = rot


func rotate_gun_to(radians: float) -> void:
	radians = wrapf(radians, 0, Constants.FULL_ROTATION)  # Restrict to a positive range
	if is_equal_approx(gun.rotation, radians):
		return
	_target_rotation = radians
	set_physics_process(true)


func set_rotation(radians: float) -> void:
	radians = wrapf(radians, 0, Constants.FULL_ROTATION)  # Restrict to a positive range
	_target_rotation = radians
	gun.rotation = radians
	set_physics_process(false)


func shoot() -> void:
	toggle_lasers(true)
	yield(get_tree().create_timer(0.4), "timeout")
	_shoot_lasers()
	yield(get_tree().create_timer(0.4), "timeout")
	toggle_lasers(false)


func explode() -> void:
	if not is_enabled:
		return
	disable()


func enable() -> void:
	is_enabled = true
	visible = true
	collider.set_deferred("disabled", false)
	laser_blocker_collider.set_deferred("disabled", false)
	toggle_lasers(true)


func disable() -> void:
	is_enabled = false
	visible = false
	collider.set_deferred("disabled", true)
	laser_blocker_collider.set_deferred("disabled", true)
	toggle_lasers(false)


func toggle_lasers(should_enable: bool) -> void:
	for laser in lasers.get_children():
		if laser.visible:
			laser.is_casting = should_enable


func _instance_lasers() -> void:
	for i in gun.hframes:
		var laser: Laser = LASER_SCENE.instance()
		laser.rotation = GUN_ROTATIONS[i]
		laser.visible = i < level
		lasers.add_child(laser)


func _shoot_lasers() -> void:
	for laser in lasers.get_children():
		laser.attack()


func _set_level(value: int) -> void:
	if value - 1 >= gun.hframes:
		push_warning("Turret level is greater than the number of gun frames available")
		return
	elif value < 0:
		push_warning("Turret level is less than 0")
		return
	level = value
	if not level:
		return
	gun.frame = level - 1
	for i in gun.hframes:
		var laser: Laser = lasers.get_child(i)
		laser.visible = i < level


func _on_Turret_input_event(_viewport: Node, event: InputEventMouseButton, _shape_idx: int) -> void:
	if event and event.button_index == BUTTON_LEFT and event.is_pressed():
		emit_signal("mouse_down")
