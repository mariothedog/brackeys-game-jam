class_name Lives
extends MarginContainer

const LIFE_SCENE := preload("res://ui/hud/health/life.tscn")

var num_lives := 0 setget _set_num_lives

onready var vbox: VBoxContainer = $VBoxContainer


func damage(damage: int) -> bool:  # Returns true if out of lives
	var new_num_lives := self.num_lives - damage
	if new_num_lives <= 0:
		new_num_lives = 0
		Signals.emit_signal("ran_out_of_lives")
	self.num_lives = new_num_lives
	return new_num_lives <= 0


func _set_num_lives(value: int) -> void:
	if value < 0:
		push_warning("Number of lives was set to a negative value")
		return
	if value == num_lives:
		return
	var diff := value - num_lives
	num_lives = value
	for i in diff:
		var life := LIFE_SCENE.instance()
		vbox.add_child(life)
	for i in -diff:
		var life := vbox.get_child(0)
		vbox.remove_child(life)
