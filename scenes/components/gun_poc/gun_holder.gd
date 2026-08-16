extends Node3D

class_name GunHolder

# export var references
@export var input_component: Node
@export var team_component: Node

# these were node tree references, but that no longer works and shit
@export var Gun_Animation: AnimationPlayer
@export var Muzzle_VFX: AnimationPlayer

@export var attached_to_player: bool

# signals
signal enemy_hit(damage: float)
signal current_gun_charge_progress_changed(progress: float)
signal current_gun_charge_ended
signal current_gun_charge_started

# define gun switches for this entity - IF player keep as per default
# IF ENEMY edit as needed 
# this used to be the const but i stopped being lazy tbh
#@export var guns_available: Array = [PISTOL_PREFAB, SHOTGUN_PREFAB, SNIPER_PREFAB]
@export var guns_available: Array[Enums.Guns]

# runtime var holding reference to currently equipped gun
var current_gun: Gun

# indexing vars for handling gun list
var current_child_count: int = 0
var current_gun_index: int = 0

# allow switch to occur - more of a bug fixing/trialling code given switches can be limited via export
var allow_swapping: bool

func _ready() -> void:
	if team_component != null:
		for guns in guns_available:
			var gun = GunList._get_gun_reference_from_enum(guns).instantiate()
			add_child(gun)
			gun.owner = self
			gun.input_component = input_component
			gun.Gun_Animation = Gun_Animation
			gun.Muzzle_VFX = Muzzle_VFX
			gun.team_component = team_component
			gun.attached_to_player = attached_to_player
			gun.enemy_hit.connect(_on_enemy_hit) # Bind all the enemy hit signals at the start so hits still heal if they land after swapping weapons
		
		current_child_count = get_child_count()
		
		# lazy code - should be changed to consider other child types...
		current_gun = get_child(current_gun_index)
		_activate_gun()
		if attached_to_player:
			EventManager.new_gun_equipped.emit(current_gun.gun_name)
			EventManager.new_mag_loaded.emit(current_gun._current_ammo, current_gun.ammo_max)
	else:
		print("ERROR = TEAM COMPONENT IS CURRENTLY NULL")

func _process(delta: float) -> void:
	var current_input_state = input_component.get_input_state()
	if current_input_state.get("switch_gun", false):
		input_component._switch_gun = false
		_switch_gun()

func _switch_gun():
	if not allow_swapping:
		return
	
	current_gun_index += 1
	if current_gun_index == current_child_count:
		current_gun_index = 0
	var rotation_save = current_gun.rotation.z
	_deactivate_gun()
	current_gun = get_child(current_gun_index)
	current_gun.rotation.z = rotation_save
	_activate_gun()
	print("GUN SWITCHED TO: ")
	print(current_gun)
	
	EventManager.new_gun_equipped.emit(current_gun.gun_name)
	EventManager.new_mag_loaded.emit(current_gun._current_ammo, current_gun.ammo_max)

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
