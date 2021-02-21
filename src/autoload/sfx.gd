extends Node

class Sound:
	var resource
	var volume_db
	var min_pitch_scale
	var max_pitch_scale
	func _init(_resource: Resource, _volume_db: float,
			   _min_pitch_scale: float, _max_pitch_scale: float) -> void:
		self.resource = _resource
		self.volume_db = _volume_db
		self.min_pitch_scale = _min_pitch_scale
		self.max_pitch_scale = _max_pitch_scale

var Sounds := {
	BULLET_HIT_TILE = Sound.new(preload("res://bullet/hit_tile.wav"), -20, 0.95, 1.05),
	TURRET_EXPLODE = Sound.new(preload("res://turret/explode.wav"), -15, 0.95, 1.05),
	ENEMY_EXPLODE = Sound.new(preload("res://enemies/explode.wav"), -20, 0.95, 1.05),
	BASE_HURT = Sound.new(preload("res://levels/base_hurt.wav"), -10, 0.95, 1.05)
}


func play_sfx(sound: Sound):
	var player := AudioStreamPlayer.new()
	player.stream = sound.resource
	player.volume_db = sound.volume_db
	player.pitch_scale = rand_range(sound.min_pitch_scale, sound.max_pitch_scale)
	assert(player.connect("finished", player, "queue_free") == OK)
	add_child(player)
	player.play()
