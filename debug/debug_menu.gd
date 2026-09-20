extends Control

@onready var no_clip_toggle: Button = $MarginContainer/PanelContainer/VBoxContainer/NoClipToggle
@onready var god_mode_toggle: Button = $MarginContainer/PanelContainer/VBoxContainer/GodModeToggle
@onready var invisible_toggle: Button = $MarginContainer/PanelContainer/VBoxContainer/InvisibleToggle
@onready var no_aggro_toggle: Button = $MarginContainer/PanelContainer/VBoxContainer/NoAggroToggle
@onready var pause_enemies_toggle: Button = $MarginContainer/PanelContainer/VBoxContainer/PauseEnemiesToggle
@onready var infinite_ammo_toggle: Button = $MarginContainer/PanelContainer/VBoxContainer/InfiniteAmmoToggle
@onready var unlock_all_guns_button: Button = $MarginContainer/PanelContainer/VBoxContainer/UnlockAllGunsButton
@onready var kill_all_button: Button = $MarginContainer/PanelContainer/VBoxContainer/KillAllButton

func _ready() -> void:
	visible = false
	DebugManager.debug_menu_open = false
	
	_setup_toggle_button(no_clip_toggle, "No Clip", DebugManager.no_clip)
	_setup_toggle_button(god_mode_toggle, "God Mode", DebugManager.god_mode)
	_setup_toggle_button(invisible_toggle, "Invisible", DebugManager.player_invisible)
	_setup_toggle_button(no_aggro_toggle, "No Aggro", DebugManager.no_aggro)
	_setup_toggle_button(pause_enemies_toggle, "Pause Enemies", DebugManager.pause_enemies)
	_setup_toggle_button(infinite_ammo_toggle, "Infinite Ammo", DebugManager.infinite_ammo)
	
	no_clip_toggle.toggled.connect(_on_no_clip_toggled)
	god_mode_toggle.toggled.connect(_on_god_mode_toggled)
	invisible_toggle.toggled.connect(_on_invisible_toggled)
	no_aggro_toggle.toggled.connect(_on_no_aggro_toggled)
	pause_enemies_toggle.toggled.connect(_on_pause_enemies_toggled)
	infinite_ammo_toggle.toggled.connect(_on_infinite_ammo_toggled)
	
	unlock_all_guns_button.pressed.connect(_on_unlock_all_guns_pressed)
	kill_all_button.pressed.connect(_on_kill_all_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_menu"):
		visible = !visible
		DebugManager.debug_menu_open = visible

func _setup_toggle_button(button: Button, label: String, enabled: bool) -> void:
	button.toggle_mode = true
	button.set_pressed_no_signal(enabled)
	button.text = label + ": ON" if enabled else label + ": OFF"

func _set_toggle_text(button: Button, label: String, enabled: bool) -> void:
	button.text = label + ": ON" if enabled else label + ": OFF"

func _on_no_clip_toggled(enabled: bool) -> void:
	DebugManager.set_no_clip(enabled)
	_set_toggle_text(no_clip_toggle, "No Clip", enabled)

func _on_god_mode_toggled(enabled: bool) -> void:
	DebugManager.set_god_mode(enabled)
	_set_toggle_text(god_mode_toggle, "God Mode", enabled)

func _on_invisible_toggled(enabled: bool) -> void:
	DebugManager.set_player_invisible(enabled)
	_set_toggle_text(invisible_toggle, "Invisible", enabled)

func _on_no_aggro_toggled(enabled: bool) -> void:
	DebugManager.set_no_aggro(enabled)
	_set_toggle_text(no_aggro_toggle, "No Aggro", enabled)

func _on_pause_enemies_toggled(enabled: bool) -> void:
	DebugManager.set_pause_enemies(enabled)
	_set_toggle_text(pause_enemies_toggle, "Pause Enemies", enabled)

func _on_infinite_ammo_toggled(enabled: bool) -> void:
	DebugManager.set_infinite_ammo(enabled)
	_set_toggle_text(infinite_ammo_toggle, "Infinite Ammo", enabled)

func _on_unlock_all_guns_pressed() -> void:
	DebugManager.unlock_all_guns()

func _on_kill_all_pressed() -> void:
	DebugManager.kill_all_enemies()
