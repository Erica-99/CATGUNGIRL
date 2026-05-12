extends CharacterBody3D
class_name ConvictEnemy

const GRAVITY = 50

@export_category("Node References")
@export var animator: AnimatedSprite3D
@export var health_comp: Node
@export var state_machine: StateMachine

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
@export var slow_down_speed: float
# How much damage needs to be taken for hitstun to happen
@export var hitstun_threshold: float

var blackboard : Dictionary 

func _ready() -> void:
	# Populates blackboard and distributes it to all states
	blackboard = {
		"actor": self,
		"anim": animator,
		"direction": direction,
		"patrol_speed": patrol_speed,
		"chase_speed": chase_speed,
		"jump_force": jump_force,
		"slow_down_speed": slow_down_speed,
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

# Basic gravity implementation
func _physics_process(delta: float) -> void:
	velocity.y -= GRAVITY * delta
	
	# Direction facing transformation
	if velocity.x < 0:
		direction = -1
		animator.flip_h = true
	elif velocity.x > 0:
		direction = 1
		animator.flip_h = false
	

# General (or Global I guess) state change conditions, such as damage taken effects, etc.
# When you don't want to write a state change function in each state.
# If you want to change state more specifically from one state to another, use that state's
# transitioned(self, "newstate") signal
func _on_health_component_killed(killing_blow: DamageHealInstance, health_before_death: Variant) -> void:
	# Possibly implement knockback affects here
	state_machine.on_child_transition(state_machine.current_state, "convictdeath")

# Hitstun "flinching", can be improved due to some jank with pounce, might not be needed with knockback implemented
func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	if (damage_or_heal_instance.amount >= hitstun_threshold):
		velocity = Vector3.ZERO
		animator.pause()
		await get_tree().create_timer(0.2).timeout
		animator.play()
