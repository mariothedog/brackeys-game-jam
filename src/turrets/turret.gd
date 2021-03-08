class_name Turret
extends Area2D

signal dead
signal mouse_down

const BULLET_SCENE := preload("res://projectiles/bullet/bullet.tscn")

const ROTATION_THRESHOLD := deg2rad(1)
const ROTATION_WEIGHT := 0.4
var ROTATION_RATE: float = ROTATION_WEIGHT * Constants.PHYSICS_FPS

export var bullet_speed := 300.0

var can_shoot := false
var can_be_shot := false setget _set_can_be_shot

var _has_bullets_node := false
var _target_rotation: float

var bullets_node: Node
onready var gun: Node2D = $Gun
onready var barrels := $Gun/Barrels.get_children()
onready var sight_lines := $Gun/SightLines.get_children()
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


func shoot() -> void:
	if not bullets_node:
		push_error("Attempting to shoot without a bullets node")
		return
	if not can_shoot:
		return
	var barrel: Position2D = barrels[0]
	var dir := barrel.position.normalized().rotated(gun.rotation)
	var bullet: Bullet = BULLET_SCENE.instance()
	bullet.global_position = barrel.global_position
	bullet.velocity = dir * bullet_speed
	bullet.rotation = dir.angle()
	bullet.friendly_turrets.append(self)
	bullets_node.add_child(bullet)


func explode() -> void:
	if is_queued_for_deletion():
		return
	queue_free()
	emit_signal("dead")


func enable_sight_lines() -> void:
	for sight_line in sight_lines:
		sight_line.is_casting = true


func disable_sight_lines() -> void:
	for sight_line in sight_lines:
		sight_line.is_casting = false


func _set_can_be_shot(value: bool) -> void:
	can_be_shot = value
	sight_blocker_collider.set_deferred("disabled", not value)


func _on_Turret_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		emit_signal("mouse_down")
