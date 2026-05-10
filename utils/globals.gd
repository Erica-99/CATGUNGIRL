extends Node

var current_level: String

# Whatever else we need here i guess

var global_insanity_level: int = 0

func _ready() -> void:
	EventManager.connect("increase_insanity_rank", _add_one_to_insanity)

# Dictionary of Levels and their UIDs, to be used
# by SceneLoader in menus, level transition points, etc.
const LEVEL_PATHS: Dictionary = {
	"test1": "res://scenes/levels/test_level.tscn",
	"test2": "res://scenes/levels/gun_test_level.tscn",
}

func _add_one_to_insanity() -> void:
	var prev_insanity = global_insanity_level
	global_insanity_level += 1
	EventManager.insanity_changed.emit(prev_insanity, global_insanity_level)
	print("Insanity Level: " + str(global_insanity_level))
