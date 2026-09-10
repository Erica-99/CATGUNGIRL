extends Node

const DEATH_SCREEN_SCENE_PATH: String = "res://scenes/ui/menu_screens/death_screen/death_screen.tscn"

var last_death_id: StringName = &"default"
var last_death_level_path: String = ""

func load_death_screen(death_id: StringName, level_path: String) -> void:
	last_death_id = death_id
	last_death_level_path = level_path
	
	get_tree().paused = false
	SceneLoader._load_scene(DEATH_SCREEN_SCENE_PATH)

func load_last_death_level() -> void:
	get_tree().paused = false
	
	var level_path_to_load: String = last_death_level_path
	
	if level_path_to_load == "":
		level_path_to_load = Globals.LEVEL_PATHS["main_menu"]
	
	get_tree().change_scene_to_file(level_path_to_load)
