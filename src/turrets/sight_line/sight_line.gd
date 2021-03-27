class_name SightLine
extends RayCast2D

var is_casting := false setget _set_is_casting

onready var hit_cast: RayCast2D = $HitCast
onready var line: Line2D = $Line2D


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


#func is_hit_cast_colliding() -> bool:
#	return hit_cast.is_colliding()


func _set_is_casting(value: bool) -> void:
	is_casting = value
	line.visible = value
	set_physics_process(value)
