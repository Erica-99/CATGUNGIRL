extends Node3D
var current_gun: Gun

signal enemy_hit(damage: float)
signal current_gun_charge_progress_changed(progress: float)
signal current_gun_charge_ended
signal current_gun_charge_started

@export var input_component: Node

@onready var Gun_Animation: AnimationPlayer = $"../PlayerVisuals/ROOT_P/GUN_P/GUN_AIM/Hand_Anims"
@onready var Muzzle_VFX: AnimationPlayer = $"../PlayerVisuals/ROOT_P/GUN_P/GUN_AIM/MuzzleFlash_P/AnimationPlayer"
@onready var team_component: Node = $"../TeamComponent"

const PISTOL_PREFAB = preload("res://scenes/components/gun_poc/pistol/pistol.tscn")
const SHOTGUN_PREFAB = preload("res://scenes/components/gun_poc/shotgun/shotgun.tscn")
#const RIFLE_PREFAB = preload("res://scenes/components/gun_poc/rifle/rifle.tscn")
const SNIPER_PREFAB = preload("res://scenes/components/gun_poc/sniper/sniper.tscn")

# can make this instead an export var for better customisation (for the poc i am being lazy)
const guns_available = [PISTOL_PREFAB, SHOTGUN_PREFAB, SNIPER_PREFAB]

var current_child_count: int = 0
var current_gun_index: int = 0

var allow_swapping: bool

func _ready() -> void:
	for guns in guns_available:
		var gun = guns.instantiate()
		add_child(gun)
		gun.owner = self
		gun.input_component = input_component
		gun.Gun_Animation = Gun_Animation
		gun.Muzzle_VFX = Muzzle_VFX
		gun.team_component = team_component
		gun.enemy_hit.connect(_on_enemy_hit) # Bind all the enemy hit signals at the start so hits still heal if they land after swapping weapons
	
	current_child_count = get_child_count()
	
	# lazy code - should be changed to consider other child types...
	current_gun = get_child(current_gun_index)
	_activate_gun()
	EventManager.new_gun_equipped.emit(current_gun.gun_name)
	EventManager.new_mag_loaded.emit(current_gun._current_ammo, current_gun.ammo_max)

func _process(_delta: float) -> void:
	var current_input_state = input_component.get_input_state()
	# Switch to next gun (Pistol -> Shotgun -> Sniper)
	if current_input_state.get("switch_gun", false):
		input_component._switch_gun = false
		_switch_gun(-1)
	
	# Switch to specific gun
	if current_input_state.get("switch_gun_one", false):
		input_component._switch_gun_one = false
		_switch_gun(0)
	if current_input_state.get("switch_gun_two", false):
		input_component._switch_gun_two = false
		_switch_gun(1)
	if current_input_state.get("switch_gun_three", false):
		input_component._switch_gun_three = false
		_switch_gun(2)

func _switch_gun(slot_num: int):
	if not allow_swapping:
		return
	
	current_child_count = get_child_count()

	if current_child_count <= 0 or current_gun == null:
		return
	
	# For "next gun" swap (Q)
	if slot_num < 0:
		if Globals.unlocked_guns.size() == 1:
			return
		current_gun_index += 1
		while (not current_gun_index in Globals.unlocked_guns) and current_gun_index < Globals.unlocked_guns.max():
			current_gun_index += 1
		if current_gun_index not in Globals.unlocked_guns:
			current_gun_index = 0
	# For specific swap (1,2,3)
	else:
		# Don't swap to current gun
		if slot_num >= current_child_count or slot_num == current_gun_index:
			return
		elif slot_num in Globals.unlocked_guns:
			current_gun_index = slot_num
		else:
			return
	var rotation_save = current_gun.rotation.z
	_deactivate_gun()
	current_gun = get_child(current_gun_index)
	current_gun.rotation.z = rotation_save
	current_gun._aim_angle = rotation_save 
	_activate_gun()
	print("GUN SWITCHED TO: ")
	print(current_gun)
	
	EventManager.new_gun_equipped.emit(current_gun.gun_name)
	EventManager.new_mag_loaded.emit(current_gun._current_ammo, current_gun.ammo_max)

func sacrifice_gun(sacrificed_gun: Gun) -> void:
	if !is_instance_valid(sacrificed_gun):
		return
	
	if sacrificed_gun.get_parent() != self:
		return
	
	var sacrificed_name: String = sacrificed_gun.gun_name
	var was_current_gun: bool = sacrificed_gun == current_gun
	var removed_index: int = sacrificed_gun.get_index()
	var rotation_save: float = sacrificed_gun.rotation.z
	
	if was_current_gun:
		_deactivate_gun()
		current_gun = null
	
	remove_child(sacrificed_gun)
	sacrificed_gun.queue_free()
	current_child_count = get_child_count()
	
	if current_child_count <= 0:
		current_gun = null
		current_gun_index = 0
		allow_swapping = false
		EventManager.enable_gun_ui.emit(false)
	
	elif was_current_gun:
		current_gun_index = removed_index
		
		if current_gun_index >= current_child_count:
			current_gun_index = 0
		
		current_gun = get_child(current_gun_index) as Gun
		current_gun.rotation.z = rotation_save
		current_gun._aim_angle = rotation_save
		_activate_gun()
		
		EventManager.new_gun_equipped.emit(current_gun.gun_name)
		EventManager.new_mag_loaded.emit(
			current_gun._current_ammo,
			current_gun.ammo_max
		)
	
	else:
		#the equipped gun remains active but its child index gets shifted
		current_gun_index = current_gun.get_index()
	
	EventManager.gun_sacrificed.emit(sacrificed_name)

func _deactivate_gun():
	current_gun.active = false
	
	current_gun.charge_progress_changed.disconnect(_on_current_gun_charge_progress_changed)
	current_gun.charge_started.disconnect(_on_current_gun_charge_started)
	current_gun.charge_ended.disconnect(_on_current_gun_charge_ended)

func _activate_gun():
	current_gun.active = true
	if current_gun._current_ammo > current_gun.ammo_max:
		current_gun._current_ammo = current_gun.ammo_max
	current_gun._fire_cooldown = 0
	current_gun._time_since_last_shot = 999
	
	# Swap the signals for current gun charge and stuff. Idk what these are for but player.gd wants them.
	current_gun.charge_progress_changed.connect(_on_current_gun_charge_progress_changed)
	current_gun.charge_started.connect(_on_current_gun_charge_started)
	current_gun.charge_ended.connect(_on_current_gun_charge_ended)

func _on_enemy_hit(damage: float) -> void:
	enemy_hit.emit(damage)
	
func _on_current_gun_charge_progress_changed(progress: float) -> void:
	current_gun_charge_progress_changed.emit(progress)

func _on_current_gun_charge_started() -> void:
	current_gun_charge_started.emit()

func _on_current_gun_charge_ended() -> void:
	current_gun_charge_ended.emit()
