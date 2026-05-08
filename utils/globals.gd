extends Node

var current_level: String

# Whatever else we need here i guess

var global_insanity_level: int = 0

# Dictionary of Levels and their uid, to be used
# by SceneLoader in menus, level transition points, etc.
const LEVEL_PATHS: Dictionary = {
	"test1": "res://scenes/levels/test_level.tscn",
	"test2": "res://scenes/levels/gun_test_level.tscn",
}
