# Power Dive State: launch upward, charge at apex, then dive toward player
extends State

enum DivePhase {
	WINDUP,
	LAUNCH,
	CHARGE,
	DIVE,
	RECOVERY
}

var actor: CharacterBody3D
var anim: AnimationPlayer
var target: CharacterBody3D

var windup_duration: float
var dive_launch_force: float
var dive_charge_duration: float
var dive_speed: float
var dive_recovery_duration: float
var slow_down_speed: float

var phase: DivePhase = DivePhase.WINDUP
var phase_timer: float = 0.0
var gravity: float
var dive_velocity: Vector3 = Vector3.ZERO
var dive_direction: Vector3 = Vector3.ZERO
var locked_target_position: Vector3 = Vector3.ZERO

@export var dive_gravity_multiplier: float = 1.0
@export var dive_horizontal_falloff: float = 0.0

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	dive_launch_force = blackboard["dive_launch_force"]
	dive_charge_duration = blackboard["dive_charge_duration"]
	dive_speed = blackboard["dive_speed"]
	dive_recovery_duration = blackboard["dive_recovery_duration"]
	slow_down_speed = blackboard["slow_down_speed"]
	windup_duration = blackboard["windup_duration"]
	gravity = blackboard["gravity"]

func enter() -> void:
	target = get_tree().get_nodes_in_group("player")[0] as CharacterBody3D
	phase = DivePhase.WINDUP
	phase_timer = 0.0
	dive_direction = Vector3.ZERO
	locked_target_position = Vector3.ZERO
	actor.velocity = Vector3.ZERO
	# anim.play("ConvictPowerDiveWindup")

func physics_update(_delta: float) -> void:
	match phase:
		DivePhase.WINDUP:
			_update_windup(_delta)
		DivePhase.LAUNCH:
			_update_launch()
		DivePhase.CHARGE:
			_update_charge(_delta)
		DivePhase.DIVE:
			_update_dive(_delta)
		DivePhase.RECOVERY:
			_update_recovery(_delta)
	actor.move_and_slide()
	
	if phase == DivePhase.DIVE and actor.get_slide_collision_count() > 0:
		_start_recovery()

func _update_windup(delta: float) -> void:
	phase_timer += delta
	actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * delta)
	
	if phase_timer >= windup_duration:
		_start_launch()

func _start_launch() -> void:
	phase = DivePhase.LAUNCH
	phase_timer = 0.0
	actor.velocity = Vector3.ZERO
	actor.velocity.y = dive_launch_force
	#anim.play("ConvictPowerDiveLaunch")

func _update_launch() -> void:
	# wait for convict to reach apex of jump
	if actor.velocity.y <= 0.0:
		_start_charge()

func _start_charge() -> void:
	phase = DivePhase.CHARGE
	phase_timer = 0.0
	actor.velocity = Vector3.ZERO
	# lock players position once so dive does not home forever
	locked_target_position = target.global_position
	locked_target_position.z = actor.global_position.z
	#anim.play("ConvictPowerDiveCharge")

func _update_charge(delta: float) -> void:
	phase_timer += delta
	actor.velocity = Vector3.ZERO
	
	if phase_timer >= dive_charge_duration:
		_start_dive()

func _start_dive() -> void:
	phase = DivePhase.DIVE
	phase_timer = 0.0
	dive_direction = locked_target_position - actor.global_position
	dive_direction.z = 0.0
	
	if dive_direction.length() == 0.0:
		dive_direction = Vector3(actor.direction, -1.0, 0.0)
	
	dive_direction = dive_direction.normalized()
	dive_velocity = dive_direction * dive_speed
	#anim.play("ConvictPowerDive")

func _update_dive(delta: float) -> void:
	dive_velocity.y -= gravity * dive_gravity_multiplier * delta
	
	if dive_horizontal_falloff > 0.0:
		dive_velocity.x = move_toward(dive_velocity.x, 0.0, dive_horizontal_falloff * delta)
	
	actor.velocity = dive_velocity

func _start_recovery() -> void:
	phase = DivePhase.RECOVERY
	phase_timer = 0.0
	actor.velocity.x = 0.0
	#anim.play("ConvictPowerDiveRecovery") if u wanna get fancy id say

func _update_recovery(delta: float) -> void:
	phase_timer += delta
	actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * delta)
	
	if phase_timer >= dive_recovery_duration:
		transitioned.emit(self, "convictchase")

func exit() -> void:
	phase = DivePhase.WINDUP
	phase_timer = 0.0
	dive_direction = Vector3.ZERO
	locked_target_position = Vector3.ZERO
