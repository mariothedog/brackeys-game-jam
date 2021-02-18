class_name Util
extends Object

static func queue_free_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

static func fposmod_snap(a: float, b: float, threshold: float) -> float:
	var mod := fposmod(a, b)
	if abs(b - mod) <= threshold:
		return 0.0
	return mod
