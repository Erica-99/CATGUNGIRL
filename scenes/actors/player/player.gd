extends CharacterBody3D

signal facing_changed(new_facing: float)
@export var hit_heal_amount: float = 5.0 


## Extending signals for ui and other components
signal player_health_initialiased(init_current_health: float, init_max_health: float)
signal player_health_changed(old_health, new_health, damage_or_heal_instance)
signal player_insanity_gained(amount, buffer)
signal player_interest_rank_changed(new_rank)
signal player_charge_progress(progress: float)
signal player_charge_ended()

@export var movement_state_machine: StateMachine

@export_category("Movement Variables")
@export var speed: float = 15.0
@export var acceleration: float = 30.0
@export var crouch_speed: float = 10.0
@export var jump_velocity: float = 25.0
@export var air_speed: float = 15.0
@export var air_acceleration: float = 20.0
@export var charge_speed_multiplier: float = 0.35

var facing: float
var speed_multiplier: float = 1.0

@export_category("Movement Dependencies")
@export var input_component: InputComponent
@export var mantle_detector: Node3D
@export var feet_point: Marker3D

var blackboard: Dictionary
@onready var gun_component = $GunComponent  
@onready var health_component = $HealthComponent

func _ready() -> void:
	blackboard = {
	"actor": self,
	"input_component": input_component,
	"mantle_detector": mantle_detector,
	"feet_point": feet_point,
	"current_mantle_target": Vector3()
	}
	
	movement_state_machine.init(blackboard)
	gun_component.enemy_hit.connect(_on_gun_enemy_hit)
	gun_component.charge_progress_changed.connect(_on_gun_charge_progress)
	gun_component.charge_ended.connect(_on_gun_charge_ended)
	gun_component.charge_started.connect(_on_gun_charge_started)
	print("player ready, gun_component: ", gun_component)

func _process(_delta: float) -> void:
	var current_state = input_component.get_input_state()
	
	if current_state["movement"] != 0:
		var new_direction = sign(current_state["movement"])
		if new_direction != facing:
			facing = new_direction
			facing_changed.emit(facing)

func _on_health_component_health_initialised(init_current_health, init_max_health):
	player_health_initialiased.emit(init_current_health, init_max_health)

func _on_health_component_health_changed(old_health, new_health, damage_or_heal_instance):
	player_health_changed.emit(old_health, new_health, damage_or_heal_instance)

func _on_insanity_component_insanity_gained(amount, buffer):
	player_insanity_gained.emit(amount, buffer)

## When Insanity reaches max, game over
func _on_insanity_component_insanity_death():
	## TODO: Death stuff
	print("Oof ouch owie I'm dead")

func _on_insanity_component_interest_rank_changed(new_rank):
	player_interest_rank_changed.emit(new_rank)
	
func _on_gun_enemy_hit(_hurtbox: Area3D) -> void:
	print("Enemy hit! Healing player by ", hit_heal_amount)
	var heal = DamageHealInstance.new()
	heal.amount = hit_heal_amount
	heal.is_heal = true
	heal.type = Enums.DamageType.NORMAL
	heal.knockback = 0.0
	heal.source = get_path()
	health_component.take_damage_or_heal(heal)
	print("Player health after heal: ", health_component.current_health)

func _on_gun_charge_progress(progress: float) -> void:
	player_charge_progress.emit(progress)

func _on_gun_charge_ended() -> void:
	player_charge_ended.emit()
	speed_multiplier = 1.0

func _on_gun_charge_started() -> void:
	speed_multiplier = charge_speed_multiplier
