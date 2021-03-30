extends Node

# warning-ignore-all:unused_class_variable

const FULL_ROTATION := TAU

var PHYSICS_FPS: int = ProjectSettings.get_setting("physics/common/physics_fps")
var WINDOW_WIDTH: int = ProjectSettings.get_setting("display/window/size/width")

enum StepTypes {
	TURRET_SHOOT,
	BULLET_MOVE,
	ENEMY_SPAWN,
	ENEMY_MOVE,
}
