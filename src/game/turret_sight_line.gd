extends RayCast2D

const LENGTH = 1000

var is_casting := false setget _set_is_casting

onready var line: Line2D = $Line2D


func _ready() -> void:
	line.visible = false
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	force_raycast_update()
	var cast_point := cast_to
	if is_colliding():
		cast_point = to_local(get_collision_point())
	line.points[1] = cast_point


func _set_is_casting(value: bool) -> void:
	is_casting = value
	line.visible = value
	set_physics_process(value)
