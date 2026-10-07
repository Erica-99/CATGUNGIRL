extends Node

signal gore_enabled_changed(enabled: bool)

const SETTINGS_PATH := "user://settings.cfg"
const DIALOGUE_BUS_NAME := "Dialogue"

## Shared absolute range every gun's aim speed slider is tunable across, so any gun
## can be tuned to feel as snappy (or as delayed) as any other
const AIM_SPEED_MIN := 1.0
const AIM_SPEED_MAX := 30.0

const PISTOL_PREFAB := preload("res://scenes/components/gun_poc/pistol/pistol.tscn")
const SHOTGUN_PREFAB := preload("res://scenes/components/gun_poc/shotgun/shotgun.tscn")
const SNIPER_PREFAB := preload("res://scenes/components/gun_poc/sniper/sniper.tscn")

var master_volume: float = 1.0
var dialogue_volume: float = 1.0
## Placeholder for the future execution/gore system
var gore_enabled: bool = true

var aim_speed_values: Dictionary = {}
var _default_aim_speeds: Dictionary = {}

func _ready() -> void:
	_ensure_bus_exists(DIALOGUE_BUS_NAME)
	_cache_default_aim_speeds()
	_load_settings()
	_apply_master_volume()
	_apply_dialogue_volume()

func _cache_default_aim_speeds() -> void:
	for prefab: PackedScene in [PISTOL_PREFAB, SHOTGUN_PREFAB, SNIPER_PREFAB]:
		var temp_gun: Gun = prefab.instantiate()
		_default_aim_speeds[temp_gun.gun_name] = temp_gun.aim_speed
		aim_speed_values[temp_gun.gun_name] = temp_gun.aim_speed
		temp_gun.free()

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

func get_aim_speed(gun_name: String) -> float:
	return aim_speed_values.get(gun_name, get_default_aim_speed(gun_name))

func get_default_aim_speed(gun_name: String) -> float:
	return _default_aim_speeds.get(gun_name, 8.0) 

func set_aim_speed(gun_name: String, value: float) -> void:
	aim_speed_values[gun_name] = clampf(value, AIM_SPEED_MIN, AIM_SPEED_MAX)
	_save_settings()

func reset_aim_speed(gun_name: String) -> float:
	var default_value := get_default_aim_speed(gun_name)
	set_aim_speed(gun_name, default_value)
	return default_value

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
	config.set_value("controls", "aim_speed_values", aim_speed_values)
	config.save(SETTINGS_PATH)

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		master_volume = config.get_value("audio", "master_volume", 1.0)
		dialogue_volume = config.get_value("audio", "dialogue_volume", 1.0)
		gore_enabled = config.get_value("gameplay", "gore_enabled", true)
		var saved_aim_speeds: Dictionary = config.get_value("controls", "aim_speed_values", {})
		for gun_name in saved_aim_speeds:
			aim_speed_values[gun_name] = saved_aim_speeds[gun_name]
