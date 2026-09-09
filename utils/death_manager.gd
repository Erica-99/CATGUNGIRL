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
	if last_death_level_path == "":
		SceneLoader._load_scene(Globals.LEVEL_PATHS["main_menu"])
		return
	
	SceneLoader._load_scene(last_death_level_path)
