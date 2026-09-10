extends Control
class_name DeathScreen

@onready var background: TextureRect = $Background
@onready var you_died_label: Label = $MainPanel/MarginContainer/ScreenVBox/YouDiedLabel
@onready var enemy_image: TextureRect = $MainPanel/MarginContainer/ScreenVBox/ContentArea/EnemyImage
@onready var enemy_info_label: Label = $MainPanel/MarginContainer/ScreenVBox/ContentArea/EnemyInfoLabel
@onready var tip_label: Label = $MainPanel/MarginContainer/ScreenVBox/ContentArea/TipLabel
@onready var continue_button: Button = $MainPanel/MarginContainer/ScreenVBox/ContentArea/ContinueButton
@onready var return_to_menu_button: Button = $MainPanel/MarginContainer/ScreenVBox/ContentArea/ReturnToMenuButton
@onready var change_difficulty_button: Button = $MainPanel/MarginContainer/ScreenVBox/ContentArea/ChangeDifficultyButton

@export_category("Scene Paths")
## Scene loaded when player chooses to return to main menu
@export var main_menu_scene_path: String = "res://scenes/ui/menu_screens/main_menu.tscn"

@export_category("Death Screen Data")
## Fallback death screen info
@export var default_death_info: DeathScreenInfo
## List of death screen entries. Add one entry per enemy/hazard type
@export var death_infos: Array[DeathScreenInfo] = []

@export_category("Loading Screen")
@export var loading_screen_scene: PackedScene = preload("res://scenes/ui/menu_screens/loading_screen/loading_screen.tscn")

var is_leaving_death_screen: bool = false

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_button_pressed)
	return_to_menu_button.pressed.connect(_on_return_to_menu_button_pressed)
	change_difficulty_button.pressed.connect(_on_change_difficulty_button_pressed)

	show_death_screen(DeathManager.last_death_id)

func show_death_screen(death_id: StringName) -> void:
	var death_info: DeathScreenInfo = get_death_info(death_id)

	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	you_died_label.text = "You Died"
	enemy_info_label.text = get_enemy_info(death_info)

	if death_info == null:
		tip_label.text = "Tip: Watch enemy patterns and use the environment to survive."
		background.texture = null
		enemy_image.texture = null
		return

	if death_info.tip == "":
		tip_label.text = "Tip: Watch enemy patterns and use the environment to survive."
	else:
		tip_label.text = "Tip: " + death_info.tip

	background.texture = death_info.background
	enemy_image.texture = death_info.enemy_image

func get_death_info(death_id: StringName) -> DeathScreenInfo:
	for death_info in death_infos:
		if death_info == null:
			continue

		if death_info.death_id == death_id:
			return death_info

	return default_death_info

func get_enemy_info(death_info: DeathScreenInfo) -> String:
	if death_info == null or death_info.enemy_info == "":
		return "Cause of death could not be identified."

	return death_info.enemy_info

func _on_continue_button_pressed() -> void:
	if is_leaving_death_screen:
		return

	is_leaving_death_screen = true
	disable_buttons()
	get_tree().paused = false

	var level_path_to_load: String = DeathManager.last_death_level_path

	if level_path_to_load == "":
		level_path_to_load = Globals.LEVEL_PATHS["main_menu"]

	load_scene(level_path_to_load)

func _on_return_to_menu_button_pressed() -> void:
	if is_leaving_death_screen:
		return

	is_leaving_death_screen = true
	disable_buttons()
	get_tree().paused = false
	load_scene(main_menu_scene_path)

func _on_change_difficulty_button_pressed() -> void:
	print("Change difficulty pressed")

func disable_buttons() -> void:
	continue_button.disabled = true
	return_to_menu_button.disabled = true
	change_difficulty_button.disabled = true

func load_scene(scene_path: String) -> void:
	if scene_path == "":
		print("Death screen tried to load an empty scene path.")
		return

	var loading_screen: LoadingScreen = loading_screen_scene.instantiate()
	loading_screen.next_scene = scene_path
	loading_screen.run_in_background = false
	loading_screen.gigi_jumpscare_visible = false
	loading_screen.set_process(false)

	get_tree().root.add_child(loading_screen)

	await loading_screen.animation_player.animation_finished
	await get_tree().process_frame

	if is_instance_valid(loading_screen):
		loading_screen.set_process(true)
