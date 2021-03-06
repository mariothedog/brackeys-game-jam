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
const SHOOT_POS_SIGN_DIRECTION_THRESHOLD := 0.00001

const ROTATION_THRESHOLD := deg2rad(1)
const ROTATION_WEIGHT := 0.3
var ROTATION_RATE: float = ROTATION_WEIGHT * Constants.PHYSICS_FPS

# warning-ignore:unused_class_variable
var item: Item
var is_enabled := true
# Turret level 0 is reserved for merged turrets
var level := 1 setget _set_level

var _target_rotation: float
var _bullets_node: Node
var _tile_size: Vector2

onready var gun: Sprite = $Gun
onready var sight_lines: Node2D = $Gun/SightLines
onready var barrel: Position2D = $Barrel
onready var collider: CollisionShape2D = $CollisionShape2D
onready var sight_blocker_collider: CollisionShape2D = $SightBlocker/CollisionShape2D
onready var anim_player: AnimationPlayer = $AnimationPlayer


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


func shoot(bullets_node: Node, tile_size: Vector2) -> void:
	_bullets_node = bullets_node
	_tile_size = tile_size
	gun.frame_coords.y = 0
	for i in level:
		var shoot_pos := barrel.position.rotated(_target_rotation).rotated(GUN_ROTATIONS[i])
		var dir := Util.sign_vec2(shoot_pos, SHOOT_POS_SIGN_DIRECTION_THRESHOLD)
		var bullet: Bullet = BULLET_SCENE.instance()
		bullet.velocity = dir * _tile_size
		bullet.friendly_turrets.append(self)
		_bullets_node.add_child(bullet)
		bullet.move_to(global_position, true)
		bullet.sprite.rotation = dir.angle()


func charge_up_gun() -> void:
	if anim_player.is_playing():
		push_warning("Attempted to start the charge up gun animation but it was already playing")
	anim_player.playback_speed = Global.step_speed
	anim_player.play("charge_gun")


func stop_charge_up_anim() -> void:
	anim_player.stop()
	gun.frame_coords.y = 0


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
	sight_lines.visible = should_enable
	for sight_line in sight_lines.get_children():
		if sight_line.visible:
			sight_line.is_casting = should_enable


func _instance_sight_lines() -> void:
	for i in gun.hframes:
		var sight_line: SightLine = SIGHT_LINE_SCENE.instance()
		sight_line.rotation = GUN_ROTATIONS[i]
		sight_line.visible = i < level
		sight_lines.add_child(sight_line)


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
		sight_line.visible = i < level


func _on_Turret_input_event(_viewport: Node, event: InputEventMouseButton, _shape_idx: int) -> void:
	if event and event.button_index == BUTTON_LEFT and event.is_pressed():
		emit_signal("mouse_down")
