extends MarginContainer

signal back_pressed

const GUN_NAMES := ["Pistol", "Shotgun", "Sniper"]

@onready var _rows: Dictionary = {
	"Pistol": {
		"slider": $VBoxContainer/PistolAimRow/SliderRow/Slider,
		"spinbox": $VBoxContainer/PistolAimRow/SliderRow/SpinBox,
		"reset_button": $VBoxContainer/PistolAimRow/HeaderRow/ResetButton,
		"default_label": $VBoxContainer/PistolAimRow/DefaultLabel,
	},
	"Shotgun": {
		"slider": $VBoxContainer/ShotgunAimRow/SliderRow/Slider,
		"spinbox": $VBoxContainer/ShotgunAimRow/SliderRow/SpinBox,
		"reset_button": $VBoxContainer/ShotgunAimRow/HeaderRow/ResetButton,
		"default_label": $VBoxContainer/ShotgunAimRow/DefaultLabel,
	},
	"Sniper": {
		"slider": $VBoxContainer/SniperAimRow/SliderRow/Slider,
		"spinbox": $VBoxContainer/SniperAimRow/SliderRow/SpinBox,
		"reset_button": $VBoxContainer/SniperAimRow/HeaderRow/ResetButton,
		"default_label": $VBoxContainer/SniperAimRow/DefaultLabel,
	},
}
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready() -> void:
	for gun_name in GUN_NAMES:
		_setup_row(gun_name)
	back_button.pressed.connect(func() -> void: back_pressed.emit())

func _setup_row(gun_name: String) -> void:
	var row: Dictionary = _rows[gun_name]
	var slider: HSlider = row["slider"]
	var spinbox: SpinBox = row["spinbox"]
	var reset_button: Button = row["reset_button"]
	var default_label: Label = row["default_label"]

	default_label.text = "Default: %.1f" % SettingsManager.get_default_aim_speed(gun_name)

	var current_value := SettingsManager.get_aim_speed(gun_name)
	slider.set_value_no_signal(current_value)
	spinbox.set_value_no_signal(current_value)

	slider.value_changed.connect(func(value: float) -> void:
		spinbox.set_value_no_signal(value)
		SettingsManager.set_aim_speed(gun_name, value)
	)
	spinbox.value_changed.connect(func(value: float) -> void:
		slider.set_value_no_signal(value)
		SettingsManager.set_aim_speed(gun_name, value)
	)
	reset_button.pressed.connect(func() -> void:
		var reset_value := SettingsManager.reset_aim_speed(gun_name)
		slider.set_value_no_signal(reset_value)
		spinbox.set_value_no_signal(reset_value)
	)
