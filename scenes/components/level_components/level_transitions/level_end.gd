# This is barely even a script, but this is an example
# of using SceneLoader._load_scene() for level transitions.
extends Area3D

# Level Names can be found in globals.gd
# TODO: find a better way to implement this, a way to
#	get a dropdown list in the inspector
@export var level_name: String

func _on_body_entered(body):
	var scene_to_load = Globals.LEVEL_PATHS.get(level_name)
	print("Entered loading zone.")
	SceneLoader._load_scene(scene_to_load)
