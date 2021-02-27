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
