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

static func is_equal_approx_vec2(a: Vector2, b: Vector2) -> bool:
	return is_equal_approx(a.x, b.x) and is_equal_approx(a.y, b.y)

static func map(function: FuncRef, arr: Array) -> Array:
	var new_arr := []
	for elem in arr:
		new_arr.append(function.call_func(elem))
	return new_arr

static func is_equal_with_threshold(a: float, b: float, threshold: float) -> bool:
	return abs(a - b) <= threshold

static func wrapf_with_threshold(value: float, minimum: float, maximum: float, threshold: float) -> float:
	if is_equal_with_threshold(value, minimum, threshold):
		return maximum
	elif is_equal_with_threshold(value, maximum, threshold):
		return minimum
	return wrapf(value, minimum, maximum)

static func reparent(node: Node, new_parent: Node) -> void:
	var old_parent = node.get_parent()
	if old_parent:
		old_parent.call_deferred("remove_child", node)
	new_parent.call_deferred("add_child", node)
