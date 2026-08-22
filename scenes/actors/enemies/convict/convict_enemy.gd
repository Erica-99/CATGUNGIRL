extends CharacterBody3D

const GRAVITY = 50

@export_category("Node References")
@export var animator: AnimationPlayer
@export var sprite: AnimatedSprite3D
@export var health_comp: Node
@export var state_machine: StateMachine
@onready var softCollider: Area3D = $SoftCollider
@export var audio_caller: Node

var is_dead: bool = false

@export_category("Starting State Variables")
@export var start_aggroed: bool
@export var patroller: bool
@export var start_idle: State
@export var start_patrol: State
@export var start_aggro: State

@export_category("Stat Variables")
# Change direction to -1 to start facing the other way
@export var direction: int = 1
@export var patrol_speed: float
@export var chase_speed: float
@export var jump_force: float
@export var accel_speed: float
@export var slow_down_speed: float
# How much damage needs to be taken for hitstun to happen
@export var body_hitstun_threshold: float
@export var body_hitstun_duration: float
@export var head_hitstun_threshold: float
@export var head_hitstun_duration: float
# horizontal pounce speed
@export var pounce_speed: float
# multiplier for slow_down_speed (hitconfirm)
@export var hit_deceleration: float

@export_category("Convict Power Dive")
##how long convicts pause before launching upwards
@export var windup_duration: float = 0.4
##how long before convict tries to power dive
@export var dive_cd: float = 4.0
##higher value causes higher jump 
@export var dive_launch_force: float = 35.0
##how long convict pauses at top before diving
@export var dive_charge_duration: float = 0.3
##speed of the dive
@export var dive_speed: float = 30
##how long convicts wait before returning to chase
@export var dive_recovery_duration: float = 0.5

@export_category("Attack Variables")
# Convict Attack Damage Stats
@export var attack_damage: float
var damage_instance: DamageHealInstance = DamageHealInstance.new()
@export var attack_hitbox: Area3D
# Used to track repeatedly hitting a still target
var target_in_hitbox: bool = false
@export var attack_cooldown_min: float
@export var attack_cooldown_max: float

var action_pending: bool = false
var enemy_manager: EnemyManager
var blackboard : Dictionary 

@onready var Convict_Piv = $Visuals

func _ready() -> void:
	# Set up Attack
	damage_instance.amount = attack_damage
	damage_instance.is_heal = false
	damage_instance.type = Enums.DamageType.NORMAL
	damage_instance.knockback = 0 # TODO: change for implementing knockback
	damage_instance.source = get_path()
	attack_hitbox.damage_or_heal_instance = damage_instance
	
	var room_convict_route_points: Array = []
	enemy_manager = _get_enemy_manager()

	if enemy_manager != null:
		room_convict_route_points =	 enemy_manager.get_convict_route_points()
	
	# Populates blackboard and distributes it to all states
	blackboard = {
		"actor": self,
		"anim": animator,
		"direction": direction,
		"patrol_speed": patrol_speed,
		"chase_speed": chase_speed,
		"jump_force": jump_force,
		"accel_speed": accel_speed,
		"slow_down_speed": slow_down_speed,
		"attack_hitbox": attack_hitbox,
		"pounce_speed": pounce_speed,
		"hit_deceleration": hit_deceleration,
		"windup_duration": windup_duration,
		"dive_cd": dive_cd,
		"dive_launch_force": dive_launch_force,
		"dive_charge_duration": dive_charge_duration,
		"dive_speed": dive_speed,
		"dive_recovery_duration": dive_recovery_duration,
		"attack_cooldown_min": attack_cooldown_min,
		"attack_cooldown_max": attack_cooldown_max,
		"convict_route_points": room_convict_route_points,
		"gravity": GRAVITY
	}
	# Change initial state based on Inspector values
	if start_aggroed:
		state_machine.initial_state = start_aggro
	else:
		if patroller:
			state_machine.initial_state = start_patrol
		else:
			state_machine.initial_state = start_idle
	state_machine.init(blackboard)

func _physics_process(delta: float) -> void:
	# Basic gravity implementation
	velocity.y -= GRAVITY * delta
	
	position.z = 0
	
	# Direction facing transformation
	if velocity.x < 0: # LEFT
		direction = -1
		#sprite.flip_h = true
		Convict_Piv.scale.x = -1
	elif velocity.x > 0: # RIGHT
		direction = 1
		#sprite.flip_h = false
		Convict_Piv.scale.x = 1

func apply_soft_collision(delta: float) -> void:
	if !softCollider.is_colliding():
		return
	
	var push_vel = softCollider.get_push_vector() * delta * 40.0
	push_vel.z = 0.0
	velocity += push_vel


# General (or Global I guess) state change conditions, such as damage taken effects, etc.
# When you don't want to write a state change function in each state.
# If you want to change state more specifically from one state to another, use that state's
# transitioned(self, "newstate") signal
func _on_health_component_killed(killing_blow: DamageHealInstance, health_before_death: Variant) -> void:
	# Possibly implement knockback affects here
	is_dead = true
	state_machine.on_child_transition(state_machine.current_state, "convictdeath")

# Hitstun "flinching", can be improved due to some jank with pounce, might not be needed with knockback implemented
func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	if damage_or_heal_instance.amount > head_hitstun_threshold:
		_apply_hitstun(head_hitstun_duration)
	elif damage_or_heal_instance.amount == body_hitstun_threshold:
		_apply_hitstun(body_hitstun_duration)

func _apply_hitstun(duration: float) -> void:
	velocity = Vector3.ZERO
	animator.pause()
	await get_tree().create_timer(duration).timeout
	animator.play()

# When the target leaves the hitbox, change value. Used to let enemy keep attacking a still target
func _on_attack_hitbox_3d_body_exited(body: Node3D) -> void:
	target_in_hitbox = false


func call_sfx_at_current_location(sfx_ref: String) -> void:
	if audio_caller == null:
		return
		
	audio_caller.play_sfx_at_location(sfx_ref, global_position)

func _get_enemy_manager() -> EnemyManager:
	var current: Node = get_parent()
	
	while current != null:
		if current is EnemyManager:
			return current
		
		current = current.get_parent()
	
	return null
