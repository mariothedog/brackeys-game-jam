class_name Bullets
extends Node2D

signal all_stopped_moving

var _num_left_till_all_stopped: int


func reset() -> void:
	Util.queue_free_children(self)
	for connection in get_signal_connection_list("all_stopped_moving"):
		var target: Object = connection.target
		var method: String = connection.method
		disconnect("all_stopped_moving", target, method)


func move(num: int) -> void:
	_num_left_till_all_stopped = get_child_count()
	for bullet in get_children():
		bullet.move(num)
		bullet.connect("stopped_moving", self, "_on_bullet_stopped_moving", [], CONNECT_ONESHOT)


func get_last() -> Bullet:
	return get_child(get_child_count() - 1) as Bullet


func _on_bullet_stopped_moving() -> void:
	_num_left_till_all_stopped -= 1
	if _num_left_till_all_stopped == 0:
		emit_signal("all_stopped_moving")
