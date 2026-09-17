extends Node

var current_level: String

# Whatever else we need here i guess

var global_insanity_level: int = 0
var health_percent_lost_per_insanity: float = 10


# variables for loading_screen.gd image loading
# has to be done in globals otherwise loading_screen.gd is gonna re-load all the files every time it gets instantiated
const link_to_meme_dir = "res://scenes/ui/menu_screens/loading_screen/meme_images/"
var meme_image_array: Array[Texture2D] = []
var current_meme_index: int = 0


func _ready() -> void:
	EventManager.connect("increase_insanity_rank", _add_one_to_insanity)
	EventManager.connect("increase_meme_index", _increment_global_meme_index)
	_retrieve_images(link_to_meme_dir)
	# get random starter index (so it doesnt start from index 0 each time)
	current_meme_index = randi_range(0, len(meme_image_array) - 1)

# Dictionary of Levels and their UIDs, to be used
# by SceneLoader in menus, level transition points, etc.
const LEVEL_PATHS: Dictionary = {
	"test1": "res://scenes/levels/test_level.tscn",
	"test2": "res://scenes/levels/gun_test_level.tscn",
	"Stage1": "res://scenes/levels/Stages/Stage1.tscn",
	"Stage2": "res://scenes/levels/Stages/Stage2.tscn",
	"Stage3": "res://scenes/levels/Stages/Stage3.tscn",
	"Stage4": "res://scenes/levels/Stages/Stage4.tscn",
	"Stage5": "res://scenes/levels/Stages/Stage5.tscn",
	"Stage6": "res://scenes/levels/Stages/Stage6.tscn",
	"main_menu": "res://scenes/ui/menu_screens/main_menu.tscn"
}

func _add_one_to_insanity() -> void:
	var prev_insanity = global_insanity_level
	global_insanity_level += 1
	EventManager.insanity_changed.emit(prev_insanity, global_insanity_level)
	print("Insanity Level: " + str(global_insanity_level))


# reference = https://www.reddit.com/r/godot/comments/1aztq6n/how_to_dynamically_load_all_resources_in_folder/
# good to use a function like this over using hardcoded stuff
	# this was added as loading_screen.gd was using hardcoded image retrieval
# this function retrieves images from a passed in directory and returns an array
func _retrieve_images(filepath: String) -> void:
	for file in ResourceLoader.list_directory(filepath):
		var image = load(filepath + file) as Texture2D
		if image:
			meme_image_array.append(image)

# increments global counter
func _increment_global_meme_index():
	current_meme_index += 1
	
	# add wrap around so it doesn't crash
	if len(meme_image_array) == current_meme_index:
		current_meme_index = 0
