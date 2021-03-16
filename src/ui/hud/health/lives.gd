class_name Lives
extends MarginContainer

const LIFE_SCENE := preload("res://ui/hud/health/life.tscn")

export var initial_num_lives := 1

var _num_lives := 0 setget _set_num_lives

onready var vbox: VBoxContainer = $VBoxContainer


func _ready() -> void:
	reset()


func damage(damage: int) -> void:
	var num_lives := self._num_lives - damage
	if num_lives <= 0:
		num_lives = 0
		Signals.emit_signal("ran_out_of_lives")
	self._num_lives = num_lives


func reset() -> void:
	self._num_lives = initial_num_lives


func _set_num_lives(value: int) -> void:
	if value < 0:
		push_warning("Number of lives was set to a negative value")
		return
	if value == _num_lives:
		return
	var diff := value - _num_lives
	_num_lives = value
	for i in diff:
		var life := LIFE_SCENE.instance()
		vbox.add_child(life)
	for i in -diff:
		var life := vbox.get_child(0)
		vbox.remove_child(life)
