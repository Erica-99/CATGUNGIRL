extends Node

signal gore_enabled_changed(enabled: bool)

const SETTINGS_PATH := "user://settings.cfg"
const DIALOGUE_BUS_NAME := "Dialogue"

var master_volume: float = 1.0
var dialogue_volume: float = 1.0
## Placeholder for the future execution/gore system
var gore_enabled: bool = true

func _ready() -> void:
	_ensure_bus_exists(DIALOGUE_BUS_NAME)
	_load_settings()
	_apply_master_volume()
	_apply_dialogue_volume()

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_master_volume()
	_save_settings()

func set_dialogue_volume(value: float) -> void:
	dialogue_volume = clampf(value, 0.0, 1.0)
	_apply_dialogue_volume()
	_save_settings()

func set_gore_enabled(enabled: bool) -> void:
	gore_enabled = enabled
	gore_enabled_changed.emit(gore_enabled)
	_save_settings()

func _apply_master_volume() -> void:
	var bus_index := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(master_volume))

func _apply_dialogue_volume() -> void:
	var bus_index := AudioServer.get_bus_index(DIALOGUE_BUS_NAME)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(dialogue_volume))

func _ensure_bus_exists(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		var bus_index := AudioServer.bus_count
		AudioServer.add_bus(bus_index)
		AudioServer.set_bus_name(bus_index, bus_name)

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "dialogue_volume", dialogue_volume)
	config.set_value("gameplay", "gore_enabled", gore_enabled)
	config.save(SETTINGS_PATH)

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		master_volume = config.get_value("audio", "master_volume", 1.0)
		dialogue_volume = config.get_value("audio", "dialogue_volume", 1.0)
		gore_enabled = config.get_value("gameplay", "gore_enabled", true)
