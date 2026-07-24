extends Node3D
var current_gun: Gun

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
	
	current_child_count = get_child_count()
	
	# lazy code - should be changed to consider other child types...
	current_gun = get_child(current_gun_index)
	_activate_gun()
	EventManager.new_gun_equipped.emit(current_gun.gun_name)
	EventManager.new_mag_loaded.emit(current_gun._current_ammo, current_gun.ammo_max)

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

func _activate_gun():
	current_gun.active = true
	if current_gun._current_ammo > current_gun.ammo_max:
		current_gun._current_ammo = current_gun.ammo_max
