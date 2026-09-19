extends Control

const LOADING_SCREEN_REFERENCE = preload("res://scenes/ui/menu_screens/loading_screen/loading_screen.tscn")

func _on_button_pressed() -> void:
	var loading_screen = LOADING_SCREEN_REFERENCE.instantiate()
	loading_screen.next_scene = Globals.LEVEL_PATHS["Stage1"]
	add_child(loading_screen)
