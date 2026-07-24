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
## Signal for when the player is D E D
signal player_dead()

@export var movement_state_machine: StateMachine

@export var gun_arm_node: Node3D

@export_category("Movement Variables")
@export var speed: float = 22.5
@export var acceleration: float = 30.0
@export var crouch_speed: float = 10.0
@export var jump_velocity: float = 25.0
@export var air_speed: float = 20.0
@export var air_acceleration: float = 35.0
@export var charge_speed_multiplier: float = 0.35

@export_category("Dash Variables")
## Distance player travels during dash
@export var dash_distance: float = 8.0
## Duration of dash
@export var dash_duration: float = 0.15
## If true, dash kills vertical movement
@export var dash_kill_movement: bool = true

@export_category("Wall Movement Variables")
##Maximum speed the player falls while sliding down a wall
@export var wall_slide_fall_speed: float = 6.0
##Sideways push into wall to help player stay attached
@export var wall_slide_stick_velocity: float = 2.0
##Horizontal force applied when the player jumps away from the wall
@export var wall_jump_horizontal_velocity: float = 20.0
##Vertical force applied when the player jumps away for the wall
@export var wall_jump_vertical_velocity: float = 10.0
##Time where air control is lockek, so the player cannot instantly move back to the wall
@export var wall_jump_control_lock_time: float = 0.15
##Maximum angle that a surface can be from a straight wall to allow sliding
@export var wall_slide_max_angle: float = 20.0

var facing: float
var enable_facing_updates: bool = true
var speed_multiplier: float = 1.0
# gun enabled by default
@export var has_gun: bool = true

@export_category("Movement Dependencies")
@export var input_component: InputComponent
@export var mantle_detector: Node3D
@export var feet_point: Marker3D
@export var jump_timer: Timer
@export var dash_timer: Timer

var blackboard: Dictionary
@onready var health_component = $HealthComponent
@onready var gun_holder: Node3D = $GunHolder

## This is to know what scene to reload when the player dies
var currentScene

func _ready() -> void:
	Engine.max_fps = 60
	blackboard = {
	"actor": self,
	"input_component": input_component,
	"mantle_detector": mantle_detector,
	"feet_point": feet_point,
	"current_mantle_target": Vector3(),
	"jump_timer": jump_timer,
	"dash_timer": dash_timer,
	"wall_jump_dir": 0.0,
	"dash_dir": 0.0,
	"can_air_dash": true,
	"gun_holder": gun_holder,
	"enable_facing_updates": enable_facing_updates
	}
	
	movement_state_machine.init(blackboard)
	gun_holder.enemy_hit.connect(_on_gun_enemy_hit)
	gun_holder.current_gun_charge_progress_changed.connect(_on_gun_charge_progress)
	gun_holder.current_gun_charge_ended.connect(_on_gun_charge_ended)
	gun_holder.current_gun_charge_started.connect(_on_gun_charge_started)
	
	EventManager.gun_picked_up.connect(_equip_gun)
	_set_gun_enabled(has_gun)

func _process(_delta: float) -> void:
	var current_state = input_component.get_input_state()
	
	if current_state["movement"] != 0 and blackboard["enable_facing_updates"]:
		set_facing(sign(current_state["movement"]))
	
	# Debug damage input
	if Input.is_action_just_pressed("debug_damage"):
		var debug_damage = DamageHealInstance.new()
		debug_damage.amount = 20
		debug_damage.is_heal = false
		debug_damage.type = Enums.DamageType.NORMAL
		debug_damage.knockback = 0
		debug_damage.source = ^"."
		
		health_component.take_damage_or_heal(debug_damage)
	
	# Debug heal input
	if Input.is_action_just_pressed("debug_heal"):
		var debug_heal = DamageHealInstance.new()
		debug_heal.amount = 10
		debug_heal.is_heal = true
		debug_heal.type = Enums.DamageType.NORMAL
		debug_heal.knockback = 0
		debug_heal.source = ^"."
		
		health_component.take_damage_or_heal(debug_heal)

func _on_health_component_health_initialised(init_current_health, init_max_health):
	EventManager.player_health_initialised.emit(init_current_health, init_max_health)

func _on_health_component_health_changed(old_health, new_health, damage_or_heal_instance):
	EventManager.player_health_changed.emit(old_health, new_health, damage_or_heal_instance)

func _on_insanity_component_insanity_gained(amount, buffer):
	EventManager.player_insanity_gained.emit(amount, buffer)

## When Insanity reaches max, game over
func _on_insanity_component_insanity_death():
	## TODO: Death stuff
	player_dead.emit()
	print("PLAYER IS DEAD")
	SceneLoader._load_scene(get_tree().current_scene.scene_file_path)

func _on_insanity_component_interest_rank_changed(new_rank):
	EventManager.player_interest_rank_changed.emit(new_rank)
	
func _on_gun_enemy_hit(_hurtbox: Area3D) -> void:
	var heal = DamageHealInstance.new()
	heal.amount = hit_heal_amount
	heal.is_heal = true
	heal.type = Enums.DamageType.NORMAL
	heal.knockback = 0.0
	heal.source = get_path()
	health_component.take_damage_or_heal(heal)

func _on_gun_charge_progress(progress: float) -> void:
	player_charge_progress.emit(progress)

func _on_gun_charge_ended() -> void:
	player_charge_ended.emit()
	speed_multiplier = 1.0

func _on_gun_charge_started() -> void:
	speed_multiplier = charge_speed_multiplier

func _equip_gun() -> void:
	has_gun = true
	_set_gun_enabled(true)

func _set_gun_enabled(enabled: bool) -> void:
	gun_holder.current_gun.process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	gun_holder.current_gun.visible = enabled
	gun_arm_node.visible = enabled
	gun_holder.allow_swapping = enabled
	
func set_facing(new_facing: float) -> void:
	if new_facing == 0.0:
		return

	if new_facing != facing:
		facing = new_facing
		facing_changed.emit(facing)
		
func get_wall_jump_dir(input_dir: float) -> float:
	if input_dir == 0.0:
		return 0.0

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()

		if normal.x == 0.0:
			continue
		#check if surface is too steep
		var is_too_steep := normal.angle_to(up_direction) > floor_max_angle
		#check if surface is a valide wall
		var side_normal := Vector3(sign(normal.x), 0.0, 0.0)
		var is_valid_wall_angle := normal.angle_to(side_normal) <= deg_to_rad(wall_slide_max_angle)
		#return the direction away from that wall if pushing into valid wall
		if is_too_steep and is_valid_wall_angle and sign(input_dir) == -sign(normal.x):
			return sign(normal.x)
	return 0.0
