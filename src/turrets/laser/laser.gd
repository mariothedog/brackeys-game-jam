class_name Laser
extends RayCast2D

var is_casting := false setget _set_is_casting

onready var line: Line2D = $Line2D
onready var attack_line: RayCast2D = $AttackLine


func _ready() -> void:
	set_physics_process(false)
	line.visible = false


func _physics_process(_delta: float) -> void:
	update()


func update() -> void:
	force_raycast_update()
	var cast_point := cast_to
	if is_colliding():
		cast_point = to_local(get_collision_point())
	line.points[1] = cast_point


func attack() -> void:
	if not is_casting:
		return
	if attack_line.is_colliding():
		var collider := attack_line.get_collider()
# warning-ignore:unsafe_method_access
		collider.explode()
		self.is_casting = false


func _set_is_casting(value: bool) -> void:
	is_casting = value
	line.visible = value
	set_physics_process(value)
