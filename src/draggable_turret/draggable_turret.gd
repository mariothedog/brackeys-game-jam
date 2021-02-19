extends TextureButton

signal reset

const ROTATION_OFFSETS = [0, 0, deg2rad(-90), 0, 0, 0, 0, 0]
const ROTATION_WEIGHT := 0.4
var ROTATION_RATE: float = ROTATION_WEIGHT * ProjectSettings.get_setting("physics/common/physics_fps")
const ROTATION_THRESHOLD := deg2rad(1)
const FULL_ROTATION_SNAP_THRESHOLD := deg2rad(1)
const FULL_ROTATION := deg2rad(360)

var _target_rotation: float

onready var gun: Sprite = $Gun
onready var base: Position2D = $Base
onready var sight_lines: Node2D = $Gun/SightLines
onready var sight_blocker_collider: CollisionShape2D = $SightBlocker/CollisionShape2D

var default_global_pos: Vector2
var level := 1 setget _set_level


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if abs(gun.rotation - _target_rotation) <= ROTATION_THRESHOLD:
		gun.rotation = _target_rotation
		set_physics_process(false)
		return
	gun.rotation = lerp_angle(gun.rotation, _target_rotation, ROTATION_RATE * delta)
	gun.rotation = Util.fposmod_snap(gun.rotation, FULL_ROTATION, FULL_ROTATION_SNAP_THRESHOLD)


func rotate_to(radians: float) -> void:
	_target_rotation = radians + ROTATION_OFFSETS[level - 1]
	if _target_rotation < 0:
		_target_rotation += FULL_ROTATION
	if abs(gun.rotation - _target_rotation) <= ROTATION_THRESHOLD:
		gun.rotation = _target_rotation
		return
	set_physics_process(true)


func reset() -> void:
	rect_global_position = default_global_pos
	self.level = 1
	set_physics_process(false)
	gun.rotation = ROTATION_OFFSETS[level - 1]
	visible = true
	if is_in_group("placed_draggable_turrets"):
		remove_from_group("placed_draggable_turrets")
	emit_signal("reset")


func enable_sight_lines() -> void:
	for sight_line in sight_lines.get_children():
		if sight_line.visible:
			sight_line.is_casting = true


func disable_sight_lines() -> void:
	for sight_line in sight_lines.get_children():
		if sight_line.visible:
			sight_line.is_casting = false


func update_sight_line() -> void:
	for sight_line in sight_lines.get_children():
		if sight_line.visible:
			sight_line.update()


func enable_sight_blocker() -> void:
	print("Sight blocker enabled")
	sight_blocker_collider.set_deferred("disabled", false)


func disable_sight_blocker() -> void:
	print("Sight blocker disabled")
	sight_blocker_collider.set_deferred("disabled", true)


func _set_level(value) -> void:
	if value == 0 or level == value:
		level = value
		return
	elif value > gun.hframes:
		level = value
		push_error("Turret level is greater than the number of gun frames available")
		return
	level = value
	gun.frame = level - 1

	for i in sight_lines.get_child_count():
		var sight_line := sight_lines.get_child(i)
		sight_line.visible = i < level
