extends PanelContainer

signal back_pressed

@onready var master_volume_slider: HSlider = $MarginContainer/VBoxContainer/MasterVolumeRow/MasterVolumeSlider
@onready var dialogue_volume_slider: HSlider = $MarginContainer/VBoxContainer/DialogueVolumeRow/DialogueVolumeSlider
@onready var gore_toggle: CheckButton = $MarginContainer/VBoxContainer/GoreRow/GoreToggle
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton

func _ready() -> void:
	master_volume_slider.value = SettingsManager.master_volume
	dialogue_volume_slider.value = SettingsManager.dialogue_volume
	gore_toggle.button_pressed = SettingsManager.gore_enabled

	master_volume_slider.value_changed.connect(SettingsManager.set_master_volume)
	dialogue_volume_slider.value_changed.connect(SettingsManager.set_dialogue_volume)
	gore_toggle.toggled.connect(SettingsManager.set_gore_enabled)
	back_button.pressed.connect(func() -> void: back_pressed.emit())
