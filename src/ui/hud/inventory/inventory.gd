extends MarginContainer

signal item_dropped(item, global_position)

const TURRET_ITEM_SCENE := preload("res://ui/hud/inventory/turret_item/turret_item.tscn")

export var num_turrets := 0

var _selected_item: TextureButton = null
var _drag_offset: Vector2

onready var items: VBoxContainer = $MarginContainer/Items


func _ready() -> void:
	for _i in num_turrets:
		var turret := TURRET_ITEM_SCENE.instance()
		assert(turret.connect("button_down", self, "_on_item_button_down", [turret]) == OK)
		assert(turret.connect("button_up", self, "_on_item_button_up", [turret]) == OK)
		items.add_child(turret)


func _process(_delta: float) -> void:
	if _selected_item:
		var pos := get_global_mouse_position() + _drag_offset
		_selected_item.drag_sprite.global_position = pos


func _on_item_button_down(item: TextureButton) -> void:
	_drag_offset = -item.base_center.position
	_selected_item = item


func _on_item_button_up(item: TextureButton) -> void:
	_selected_item = null
	item.drag_sprite.position = Vector2.ZERO
	emit_signal("item_dropped", item, get_global_mouse_position())
