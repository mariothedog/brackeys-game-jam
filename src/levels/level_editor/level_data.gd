class_name LevelData
extends Resource

# warning-ignore-all:unused_class_variable

export var tiles := {}
export var enemy_paths := []
export var num_lives: int
export var num_turrets: int
export var num_enemies: int
export var enemy_group_size: int  # -1 means no groups (they continuously spawn)
export var step_types: Array
