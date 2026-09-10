# This is barely even a script, but this is an example
# of using SceneLoader._load_scene() for level transitions.
extends Area3D

# reference to loading screen entity
const LOADING_SCREEN_REFERENCE = preload("res://scenes/ui/menu_screens/loading_screen/loading_screen.tscn")

# Level Names can be found in globals.gd
# TODO: find a better way to implement this, a way to
#	get a dropdown list in the inspector
@export var level_name: String

# add export bool for gigi jumpscare - done this way so stuff doesnt break if we change the boss stage name later
@export var loading_screen_jumpscare: bool = false

func _on_body_entered(body):
	var loading_screen = LOADING_SCREEN_REFERENCE.instantiate()
	loading_screen.next_scene = Globals.LEVEL_PATHS.get(level_name)
	loading_screen.gigi_jumpscare_visible = loading_screen_jumpscare
	add_child(loading_screen)
	
	# old setup below (preserved just in case loading screens are not wanted)
	#var scene_to_load = Globals.LEVEL_PATHS.get(level_name)
	#print("Entered loading zone.")
	#SceneLoader._load_scene(scene_to_load)
