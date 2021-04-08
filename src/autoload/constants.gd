extends Node

# warning-ignore-all:unused_class_variable

# Math
const FULL_ROTATION := TAU

# Project settings
var PHYSICS_FPS: int = ProjectSettings.get_setting("physics/common/physics_fps")
var WINDOW_WIDTH: int = ProjectSettings.get_setting("display/window/size/width")

# Format paths
const FORMAT_LEVEL_PATH := "res://levels/resources/level_%s.tres"
