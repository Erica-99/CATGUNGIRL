# Based on tutorial by Queble
# https://www.youtube.com/watch?v=m4PfHg3hmSo
extends Node

# Emits when the progress of the load changes
signal progress_changed(progress)
# Emit when the load has finished
signal load_finished

var loading_screen: PackedScene = preload("res://scenes/ui/menu_screens/loading_screen/loading_screen.tscn")
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
# If this is set to true, the scene loader will try to load
# scenes using multiple threads in the background. Should be
# faster but if it causes problems set to false
var use_sub_threads: bool = true

func _ready() -> void:
	# Processing only happens when a scene is being loaded
	set_process(false)

# Call _load_scene globally with the string of the scene path.
# Brings up the loading screen, when loading is up, start to load new scene.
func _load_scene(_scene_path: String) -> void:
	scene_path = _scene_path
	
	var new_load_screen = loading_screen.instantiate()
	add_child(new_load_screen)
	
	progress_changed.connect(new_load_screen._on_progress_changed)
	load_finished.connect(new_load_screen._on_load_finished)
	
	await new_load_screen.loading_screen_ready
	
	start_load()

# If new scene is okay to be loaded, start processing
func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

# Get status of load, once new scene is loaded change to it
func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			print("Scene loader error: " + str(load_status))
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			get_tree().change_scene_to_packed(loaded_resource)
			load_finished.emit()
			set_process(false)
