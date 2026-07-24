extends CharacterBody3D

@export_category("Node References")
@export var animator: AnimatedSprite3D
@export var animation_manager: AnimationPlayer
@export var state_machine: StateMachine

@export_category("Starting State Variables")
@export var start_aggroed: bool
@export var patroller: bool
@export var start_idle: State
@export var start_patrol: State
@export var start_aggro: State

@onready var health_comp = $HealthComponent
@export var gun_component: Node3D

@export_category("Autoswitch State Variables")
@export var min_idle_time: float = 1.0
@export var max_idle_time: float = 3.0
@export var min_patrol_time: float = 4.0
@export var max_patrol_time: float = 6.0

@export_category("Stat Variables")
@export var direction: int = 1
@export var move_speed: float = 10
@export var chase_speed: float
@export var change_sprite_on_half_hp: bool = true

#Trunk Visual Code
@onready var InjuredFrames = preload("res://art/2d_assets/real_world/Trunks/TrunkInjured.tres")
@onready var sprite_anims = $TrunkMesh/TorsoAnims
@onready var torso_sprite = $TrunkMesh/Torso/TorsoSprite
var current_step: String

var facing: float = 1.0:
	set(value):
		if value != facing:
			facing = value
			current_time_between_steps = base_time_between_steps
			facing_changed.emit(self)

@export_category("Hitstun Variables")
@export var body_hitstun_threshold: float
@export var body_hitstun_duration: float
@export var head_hitstun_threshold: float
@export var head_hitstun_duration: float

@export_category("State Controlling Variables")
@export var detected_player: bool = false

@export_category("Patrol State Modifiers")
@export var patrol_speed: float
@export var elapsed_direction_switch: float

@export_category("Chase State Modifiers")
@export var xpos_distance_vert_offset: float
@export var vert_threshold: float

@export_category("Melee State Modifiers")
@export var xpos_distance_to_melee: float
@export var melee_stop_speed: float
@export var melee_windup_time: float = 0.5
@export var melee_lunge_distance: float = 3.0
@export var melee_lunge_duration: float = 0.2
@export var melee_recovery_time: float = 5.0

@export_category("Attack Variables")
@export var melee_damage: float = 30.0
@export var melee_hitbox: Area3D

@export_category("Walking Variables")
@export var distance_per_step: float = 2.0
@export var base_time_between_steps: float = 0.0
@export var min_time_between_steps: float = 0.00
@export var exponential_decrement_per_step: float = 0.0

@export_category("Outrange Timeout")
@export var time_till_outrange: float = 6.0

var current_time_between_steps: float
var can_take_step: bool = true
var past_platform_collider_status: bool = true
var past_object_collider_status: bool = false

@onready var step_handler: Timer = $StepHandler
@onready var outranged_timer: Timer = $OutrangedTimer
@onready var platform_check: RayCast3D = $PlatformCheck
@onready var object_check: RayCast3D = $ObjectCheck
@onready var animation_player: AnimationPlayer = $TrunkMesh/TorsoAnims
@onready var chase_range: Area3D = $ChaseRange

var damage_instance: DamageHealInstance = DamageHealInstance.new()

var in_attacking_range: bool

signal facing_changed(trunk: CharacterBody3D)
signal cant_step(status: bool)

var is_dead: bool = false
var blackboard: Dictionary
var under_half_hp: bool = false

const GRAVITY = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damage_instance.amount = melee_damage
	damage_instance.is_heal = false
	damage_instance.type = Enums.DamageType.NORMAL
	damage_instance.knockback = 0
	damage_instance.source = get_path()
	melee_hitbox.damage_or_heal_instance = damage_instance
	
	outranged_timer.wait_time = time_till_outrange
	_reset_step_handler()
	
	# Blackboard contains the information states will use
	blackboard = {
		# Actor for movement stats
		"actor": self,
		"anim": animator,
		"animation_manager": animation_manager,
		"direction": direction,
		"gun_component": gun_component,
		"patrol_speed": patrol_speed,
		"chase_speed": chase_speed,
		"min_idle_time": min_idle_time,
		"max_idle_time": max_idle_time,
		"min_patrol_time": min_patrol_time,
		"max_patrol_time": max_patrol_time,
		"elapsed_direction_switch": elapsed_direction_switch,
		"xpos_distance_to_melee": xpos_distance_to_melee,
		"melee_stop_speed": melee_stop_speed,
		"melee_hitbox": melee_hitbox,
		"melee_damage": melee_damage,
		"melee_windup_time": melee_windup_time,
		"melee_lunge_distance": melee_lunge_distance,
		"melee_lunge_duration": melee_lunge_duration,
		"melee_recovery_time": melee_recovery_time,
		"xpos_distance_vert_offset": xpos_distance_vert_offset,
		"vert_threshold": vert_threshold,
		"target": get_tree().get_first_node_in_group("player") as CharacterBody3D,
	}
	# Change initial state based on Inspector values
	if start_aggroed:
		state_machine.initial_state = start_aggro
	else:
		if patroller:
			state_machine.initial_state = start_patrol
		else:
			state_machine.initial_state = start_idle
	# Initialise state machine with Scrub information
	state_machine.init(blackboard)
	
func _process(delta):
	_handle_collision_check()

func _physics_process(delta: float) -> void:
	velocity.y -= GRAVITY * delta
	move_and_slide()

func _on_health_component_killed(killing_blow: DamageHealInstance, health_before_death: Variant) -> void:
	# Possibly implement knockback affects here
	is_dead = true
	state_machine.on_child_transition(state_machine.current_state, "trunkdeath")

func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	if !detected_player && !is_dead:
		detected_player = true
		state_machine.on_child_transition(state_machine.current_state, "trunkchase")
	
	if new_health < health_comp.starting_health and change_sprite_on_half_hp and !under_half_hp:
		under_half_hp = true
		
		torso_sprite.sprite_frames = InjuredFrames
		print("yo im under half hp rn type shit")

func _reset_step_handler():
	current_time_between_steps = base_time_between_steps
	#step_handler.wait_time = base_time_between_steps
	#step_handler.start()
	
func _stop_step_handler():
	step_handler.stop()

func _take_step():
	if can_take_step:
		global_position.x += distance_per_step * facing


func _on_torso_anims_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'StepFront' or anim_name == 'StepBack':
		step_handler.start()
	elif anim_name == 'StepStart':
		animation_player.play('StepBack')
	pass # Replace with function body.
func _step(currentstep):
	if currentstep == 'StepFront':
		animation_player.play("StepBack")
	elif currentstep == 'StepBack':
		animation_player.play("StepFront")
	else:
		animation_player.play("StepStart")

func _on_step_handler_timeout() -> void:
	_step(sprite_anims.get_assigned_animation())
	
	await animation_player.animation_finished
	current_time_between_steps = max(current_time_between_steps * exponential_decrement_per_step, min_time_between_steps)
	
	#step_handler.wait_time = current_time_between_steps


func _handle_collision_check():
	platform_check.force_raycast_update()
	object_check.force_raycast_update()
	# platform_check should always be colliding, object_check should never be colliding
	if past_platform_collider_status != platform_check.is_colliding() or past_object_collider_status != object_check.is_colliding():
		past_platform_collider_status = platform_check.is_colliding()
		past_object_collider_status = object_check.is_colliding()
		
		can_take_step = past_platform_collider_status and !past_object_collider_status
		
		if !can_take_step:
			if detected_player:
				outranged_timer.start()
				cant_step.emit(true)
		else:
			outranged_timer.stop()
			if state_machine.current_state is TrunkOutranged:
				state_machine.on_child_transition(state_machine.current_state, "trunkchase")

func _on_outranged_timer_timeout() -> void:
	state_machine.on_child_transition(state_machine.current_state, "trunkoutranged")
