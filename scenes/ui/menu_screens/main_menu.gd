extends Control

const LOADING_SCREEN_REFERENCE = preload("res://scenes/ui/menu_screens/loading_screen/loading_screen.tscn")

@export var level_name_to_load: String

func _ready() -> void:
	AudioManager.play_music("music_menu")
	Globals._reset_game()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		print("GOOD JOB!")
		if Input.is_action_just_pressed("ui_accept"):
			print("ACCEPT PRESSED!")
			_on_button_pressed()

func _on_button_pressed() -> void:
	var loading_screen = LOADING_SCREEN_REFERENCE.instantiate()
	loading_screen.next_scene = Globals.LEVEL_PATHS.get(level_name_to_load)
	add_child(loading_screen)
	loading_screen.initialise()
