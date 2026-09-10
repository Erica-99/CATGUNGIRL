extends Node

const DEATH_SCREEN_SCENE_PATH: String = "res://scenes/ui/menu_screens/death_screen/death_screen.tscn"
var last_death_id: StringName = &"default"
var last_death_level_path: String = ""
var is_loading_death_screen: bool = false
var is_loading_last_level: bool = false

func load_death_screen(death_id: StringName, level_path: String) -> void:
	if is_loading_death_screen:
		return
	
	is_loading_death_screen = true
	last_death_id = death_id
	last_death_level_path = level_path
	get_tree().paused = false
	await get_tree().process_frame
	SceneLoader._load_scene(DEATH_SCREEN_SCENE_PATH)
	await SceneLoader.load_finished
	is_loading_death_screen = false
#make changes for loading screen later
func load_last_death_level() -> void:
	get_tree().paused = false
	var level_path_to_load: String = last_death_level_path
	
	if level_path_to_load == "":
		level_path_to_load = Globals.LEVEL_PATHS["main_menu"]
	
	await get_tree().process_frame
	get_tree().change_scene_to_file(level_path_to_load)
