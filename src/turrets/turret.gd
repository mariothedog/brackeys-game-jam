class_name Turret
extends Area2D

signal mouse_down

const BULLET_SCENE := preload("res://projectiles/bullet/bullet.tscn")

const ROTATION_THRESHOLD := deg2rad(1)
const ROTATION_WEIGHT := 0.4
var ROTATION_RATE: float = ROTATION_WEIGHT * Constants.PHYSICS_FPS

export var bullet_speed := 300.0

var is_enabled := true
# Turret level 0 is reserved for merged turrets
var level := 1 setget _set_level
var can_shoot := false

var _target_rotation: float

var bullets_node: Node
onready var gun: Sprite = $Gun
onready var sight_lines := $Gun/SightLines.get_children()
onready var barrel: Position2D = $Barrel
onready var collider: CollisionShape2D = $CollisionShape2D
onready var sight_blocker_collider: CollisionShape2D = $SightBlocker/CollisionShape2D


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


func shoot() -> void:
	if not bullets_node:
		push_error("Attempting to shoot without a bullets node")
		return
	if not can_shoot:
		return
	var shoot_pos := barrel.position.rotated(_target_rotation)
	var dir := shoot_pos.normalized()
	var bullet: Bullet = BULLET_SCENE.instance()
	bullet.global_position = global_position + shoot_pos
	bullet.velocity = dir * bullet_speed
	bullet.rotation = dir.angle()
	bullet.friendly_turrets.append(self)
	bullets_node.add_child(bullet)


func explode() -> void:
	if not is_enabled:
		return
	disable()


func enable() -> void:
	is_enabled = true
	visible = true
	collider.set_deferred("disabled", false)
	sight_blocker_collider.set_deferred("disabled", false)
	enable_sight_lines()


func disable() -> void:
	is_enabled = false
	visible = false
	collider.set_deferred("disabled", true)
	sight_blocker_collider.set_deferred("disabled", true)
	disable_sight_lines()


func enable_sight_lines() -> void:
	for sight_line in sight_lines:
		sight_line.is_casting = true


func disable_sight_lines() -> void:
	for sight_line in sight_lines:
		sight_line.is_casting = false


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


func _on_Turret_input_event(_viewport: Node, event: InputEventMouseButton, _shape_idx: int) -> void:
	if event and event.button_index == BUTTON_LEFT and event.is_pressed():
		emit_signal("mouse_down")
