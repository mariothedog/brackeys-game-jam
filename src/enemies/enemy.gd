extends Area2D

var speed: float
var path: PoolVector2Array setget _set_path


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	var displacement := speed * delta
	move_along_path(displacement)
	if path.size() == 1:
		queue_free()


func move_along_path(dist: float) -> void:
	var start_point := position
	for i in path.size():
		var dist_to_next := start_point.distance_to(path[0])
		if dist <= dist_to_next and dist >= 0.0:
			position = start_point.linear_interpolate(path[0], dist / dist_to_next)
			break
		elif dist < 0.0:
			position = path[0]
			set_physics_process(false)
			break
		dist -= dist_to_next
		start_point = path[0]
		path.remove(0)


func explode() -> void:
	queue_free()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "vanish":
		queue_free()


func _set_path(value) -> void:
	path = value
	if not path:
		return
	set_physics_process(true)
