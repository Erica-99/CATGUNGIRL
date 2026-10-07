extends Control

@onready var button = $Button

const LOADING_SCREEN_REFERENCE = preload("res://scenes/ui/menu_screens/loading_screen/loading_screen.tscn")
var using_controller: bool = false

func _ready() -> void:
	AudioManager.play_music("test_music")

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		_on_button_pressed()

func _on_button_pressed() -> void:
	var loading_screen = LOADING_SCREEN_REFERENCE.instantiate()
	loading_screen.next_scene = Globals.LEVEL_PATHS["Stage1"]
	add_child(loading_screen)
