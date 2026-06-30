extends Node3D
var current_gun: Base_Gun

@export var input_component: Node

@onready var Gun_Animation: AnimationPlayer = $"../PlayerVisuals/ROOT_P/GUN_P/GUN_AIM/Hand_Anims"
@onready var Muzzle_VFX: AnimationPlayer = $"../PlayerVisuals/ROOT_P/GUN_P/GUN_AIM/MuzzleFlash_P/AnimationPlayer"
const PISTOL_PREFAB = preload("res://scenes/components/gun_poc/pistol.tscn")

func _ready() -> void:
	current_gun = PISTOL_PREFAB.instantiate()
	add_child(current_gun)
	current_gun.owner = self

func _process(delta: float) -> void:
	var current_input_state = input_component.get_input_state()
	if current_input_state.get("fire_held", false):
		_fire()


func _fire() -> void:
	current_gun._try_fire()
