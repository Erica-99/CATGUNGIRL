extends PanelContainer

signal back_pressed

@onready var audio_page: MarginContainer = $AudioPage
@onready var master_volume_slider: HSlider = $AudioPage/VBoxContainer/MasterVolumeRow/MasterVolumeSlider
@onready var dialogue_volume_slider: HSlider = $AudioPage/VBoxContainer/DialogueVolumeRow/DialogueVolumeSlider
@onready var gore_toggle: CheckButton = $AudioPage/VBoxContainer/GoreRow/GoreToggle
@onready var controls_button: Button = $AudioPage/VBoxContainer/ControlsButton
@onready var back_button: Button = $AudioPage/VBoxContainer/BackButton
@onready var controls_panel: MarginContainer = $ControlsPanel

func _ready() -> void:
	master_volume_slider.value = SettingsManager.master_volume
	dialogue_volume_slider.value = SettingsManager.dialogue_volume
	gore_toggle.button_pressed = SettingsManager.gore_enabled

	master_volume_slider.value_changed.connect(SettingsManager.set_master_volume)
	dialogue_volume_slider.value_changed.connect(SettingsManager.set_dialogue_volume)
	gore_toggle.toggled.connect(SettingsManager.set_gore_enabled)
	controls_button.pressed.connect(_on_controls_pressed)
	back_button.pressed.connect(func() -> void: back_pressed.emit())
	controls_panel.back_pressed.connect(_show_audio_page)

# opens audio page first when clicking settings
	visibility_changed.connect(func() -> void:
		if visible:
			_show_audio_page()
	)

func _on_controls_pressed() -> void:
	audio_page.visible = false
	controls_panel.visible = true

func _show_audio_page() -> void:
	audio_page.visible = true
	controls_panel.visible = false
