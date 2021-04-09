class_name Util
extends Object

static func get_Vector2(vec: Vector3) -> Vector2:
	return Vector2(vec.x, vec.y)

static func get_Vector3(vec: Vector2) -> Vector3:
	return Vector3(vec.x, vec.y, 0)

static func get_PoolVector2Array(arr: PoolVector3Array) -> PoolVector2Array:
	var array := PoolVector2Array()
	for vec in arr:
		array.append(get_Vector2(vec))
	return array

static func map(function: FuncRef, arr: Array) -> Array:
	var new_arr := []
	for elem in arr:
		new_arr.append(function.call_func(elem))
	return new_arr

static func is_equal_with_threshold(a: float, b: float, threshold: float) -> bool:
	return abs(a - b) <= threshold

static func is_vec2_equal_with_threshold(a: Vector2, b: Vector2, threshold: float) -> bool:
	return abs(a.x - b.x) <= threshold and abs(a.y - b.y) <= threshold

static func wrapf_with_threshold(value: float, minimum: float, maximum: float, threshold: float) -> float:
	if is_equal_with_threshold(value, minimum, threshold):
		return maximum
	elif is_equal_with_threshold(value, maximum, threshold):
		return minimum
	return wrapf(value, minimum, maximum)

static func queue_free_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

static func deferred_free_children(node: Node) -> void:
	for child in node.get_children():
		child.call_deferred("free")

static func sign_vec2(vec: Vector2, threshold: float) -> Vector2:
	var new_vec := Vector2()
	if vec.x > threshold:
		new_vec.x = 1
	elif vec.x < -threshold:
		new_vec.x = -1
	if vec.y > threshold:
		new_vec.y = 1
	elif vec.y < -threshold:
		new_vec.y = -1
	return new_vec

static func disconnect_safe(object: Object, object_signal: String, target: Object, method: String) -> void:
	if object.is_connected(object_signal, target, method):
		object.disconnect(object_signal, target, method)

static func connect_safe(
	object: Object, object_signal: String, target: Object, method: String, binds: Array, flags := 0
) -> void:
	if not object.is_connected(object_signal, target, method):
# warning-ignore:return_value_discarded
		object.connect(object_signal, target, method, binds, flags)

static func distance_between_manhattan(a: Vector2, b: Vector2) -> float:
	return abs(b.x - a.x) + abs(b.y - a.y)

static func lerp_through_points(from: Vector2, to: Vector2, points: PoolVector2Array, weight: float) -> Array:
	# Returns [new position, points left over]
	var new_pos := from
	var dist := distance_between_manhattan(from, to)
	var dist_to_move := dist * weight
	var next_point := points[0]
	var dist_to_next_point := distance_between_manhattan(from, next_point)
	var ratio_to_next_point := dist_to_move / dist_to_next_point
	while ratio_to_next_point >= 1:
		dist_to_move -= dist_to_next_point
		new_pos = next_point
		points.remove(0)
		next_point = points[0]
		dist_to_next_point = distance_between_manhattan(new_pos, next_point)
		ratio_to_next_point = dist_to_move / dist_to_next_point
	if ratio_to_next_point < 1:
		new_pos += ratio_to_next_point * (next_point - new_pos)
	return [new_pos, points]
