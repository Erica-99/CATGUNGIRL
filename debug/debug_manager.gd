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
	var enemy_managers: Array = []
	_find_enemy_managers(get_tree().current_scene, enemy_managers)
	
	for enemy_manager in enemy_managers:
		enemy_manager.kill_all_enemies()

func _find_enemy_managers(node: Node, enemy_managers: Array) -> void:
	if node is EnemyManager:
		enemy_managers.append(node)
	
	for child in node.get_children():
		_find_enemy_managers(child, enemy_managers)

func reset_debug_values() -> void:
	debug_menu_open = false
	no_clip = false
	god_mode = false
	player_invisible = false
	no_aggro = false
	pause_enemies = false
	infinite_ammo = false
	all_guns_unlocked = false
