class_name Turret
extends Area2D

signal mouse_down

const SIGHT_LINE_SCENE := preload("res://turrets/sight_line/sight_line.tscn")
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

export var bullet_speed := 300.0

# warning-ignore:unused_class_variable
var item: Item
var is_enabled := true
# Turret level 0 is reserved for merged turrets
var level := 1 setget _set_level

var _target_rotation: float

onready var gun: Sprite = $Gun
onready var sight_lines := $Gun/SightLines
onready var barrel: Position2D = $Barrel
onready var collider: CollisionShape2D = $CollisionShape2D
onready var sight_blocker_collider: CollisionShape2D = $SightBlocker/CollisionShape2D


func _ready() -> void:
	set_physics_process(false)
	_instance_sight_lines()


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
	if is_equal_approx(_target_rotation, radians):
		return
	_target_rotation = radians
	set_physics_process(true)


func set_rotation(radians: float) -> void:
	radians = wrapf(radians, 0, Constants.FULL_ROTATION)  # Restrict to a positive range
	_target_rotation = radians
	gun.rotation = radians
	set_physics_process(false)


func shoot(bullets_node: Node) -> void:
	for i in level:
		var sight_line: SightLine = sight_lines.get_child(i)
		if sight_line.is_colliding() and sight_line.get_collider().name == "SightBlocker":  # Temporary hack
			yield(get_tree().create_timer(0.5), "timeout")
		var shoot_pos := barrel.position.rotated(_target_rotation).rotated(GUN_ROTATIONS[i])
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
	toggle_sight_lines(true)


func disable() -> void:
	is_enabled = false
	visible = false
	collider.set_deferred("disabled", true)
	sight_blocker_collider.set_deferred("disabled", true)
	toggle_sight_lines(false)


func toggle_sight_lines(should_enable: bool) -> void:
	for sight_line in sight_lines.get_children():
		if sight_line.is_casting:
			sight_line.visible = should_enable


func _instance_sight_lines() -> void:
	for i in gun.hframes:
		var sight_line: SightLine = SIGHT_LINE_SCENE.instance()
		sight_line.rotation = GUN_ROTATIONS[i]
		sight_lines.add_child(sight_line)
		sight_line.is_casting = i < level


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
		var sight_line: SightLine = sight_lines.get_child(i)
		sight_line.is_casting = i < level


func _on_Turret_input_event(_viewport: Node, event: InputEventMouseButton, _shape_idx: int) -> void:
	if event and event.button_index == BUTTON_LEFT and event.is_pressed():
		emit_signal("mouse_down")
