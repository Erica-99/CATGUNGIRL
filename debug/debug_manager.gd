extends Node

var debug_menu_open: bool = false

#toggles
var no_clip: bool = false
var god_mode: bool = false
var player_invisible: bool = false
var no_aggro: bool = false
var pause_enemies: bool = false
var infinite_ammo: bool = false
var all_guns_unlocked: bool = false

func set_no_clip(enabled: bool) -> void:
	no_clip = enabled
	print("No Clip: ", no_clip)

func set_god_mode(enabled: bool) -> void:
	god_mode = enabled
	print("God Mode: ", god_mode)

func set_player_invisible(enabled: bool) -> void:
	player_invisible = enabled
	print("Player Invisible: ", player_invisible)

func set_no_aggro(enabled: bool) -> void:
	no_aggro = enabled
	print("No Aggro: ", no_aggro)

func set_pause_enemies(enabled: bool) -> void:
	pause_enemies = enabled
	print("Pause Enemies: ", pause_enemies)

func set_infinite_ammo(enabled: bool) -> void:
	infinite_ammo = enabled
	print("Infinite Ammo: ", infinite_ammo)

func unlock_all_guns() -> void:
	all_guns_unlocked = true
	print("Unlock All Guns")

func kill_all_enemies() -> void:
	print("Kill All Enemies")

func reset_debug_values() -> void:
	debug_menu_open = false
	no_clip = false
	god_mode = false
	player_invisible = false
	no_aggro = false
	pause_enemies = false
	infinite_ammo = false
	all_guns_unlocked = false
