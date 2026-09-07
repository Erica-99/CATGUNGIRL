extends CanvasLayer

@onready var menu_root: Control = $MenuRoot
@onready var main_panel: PanelContainer = $MenuRoot/CenterContainer/MainPanel
@onready var resume_button: Button = $MenuRoot/CenterContainer/MainPanel/MarginContainer/VBoxContainer/ResumeButton
@onready var settings_button: Button = $MenuRoot/CenterContainer/MainPanel/MarginContainer/VBoxContainer/SettingsButton
@onready var restart_button: Button = $MenuRoot/CenterContainer/MainPanel/MarginContainer/VBoxContainer/RestartButton
@onready var main_menu_button: Button = $MenuRoot/CenterContainer/MainPanel/MarginContainer/VBoxContainer/MainMenuButton
@onready var quit_button: Button = $MenuRoot/CenterContainer/MainPanel/MarginContainer/VBoxContainer/QuitButton
@onready var settings_panel: PanelContainer = $MenuRoot/CenterContainer/SettingsPanel

var _is_paused: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	menu_root.visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	settings_panel.back_pressed.connect(_on_settings_back_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()
		get_viewport().set_input_as_handled()

func _toggle_pause() -> void:
	_is_paused = not _is_paused
	get_tree().paused = _is_paused
	menu_root.visible = _is_paused
	if _is_paused:
		_show_main_panel()
		resume_button.grab_focus()

func _show_main_panel() -> void:
	main_panel.visible = true
	settings_panel.visible = false

func _on_resume_pressed() -> void:
	_toggle_pause()

func _on_settings_pressed() -> void:
	main_panel.visible = false
	settings_panel.visible = true

func _on_settings_back_pressed() -> void:
	_show_main_panel()

func _on_restart_pressed() -> void:
	_unpause()
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	_unpause()
	SceneLoader._load_scene(Globals.LEVEL_PATHS["main_menu"])

func _on_quit_pressed() -> void:
	get_tree().quit()

func _unpause() -> void:
	get_tree().paused = false
	_is_paused = false
	menu_root.visible = false
