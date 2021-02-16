extends Node


func reparent(node, new_parent):
	node.get_parent().remove_child(node)
	new_parent.add_child(node)
