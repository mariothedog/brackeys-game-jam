extends Node2D

const TURRET_SCENE = preload("res://turrets/turret.tscn")

export (NodePath) var level_path

var _selected_turret: Turret

onready var level: TileMap = get_node(level_path)


func _ready() -> void:
	set_process(false)
# warning-ignore:return_value_discarded
	Signals.connect("item_button_down", self, "_on_item_button_down")
# warning-ignore:return_value_discarded
	Signals.connect("item_button_up", self, "_on_item_button_up")
# warning-ignore:return_value_discarded
	Signals.connect("draggable_turret_button_down", self, "_on_draggable_turret_button_down")
# warning-ignore:return_value_discarded
	Signals.connect("draggable_turret_button_up", self, "_on_draggable_turret_button_up")


func _process(_delta: float) -> void:
	_selected_turret.position = get_local_mouse_position()


func _on_item_button_down(_item: Item) -> void:
	var turret: Turret = TURRET_SCENE.instance()
	_selected_turret = turret
	_selected_turret.position = get_local_mouse_position()
	add_child(turret)
	set_process(true)


func _on_item_button_up(_item: Item) -> void:
	set_process(false)
	_selected_turret = null


func _on_draggable_turret_button_down(turret: Turret) -> void:
	_selected_turret = turret
	set_process(true)


func _on_draggable_turret_button_up(_turret: Turret) -> void:
	set_process(false)
	_selected_turret = null
