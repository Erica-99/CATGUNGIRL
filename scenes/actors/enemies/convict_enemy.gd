extends CharacterBody3D
class_name ConvictEnemy

# Node References
@export var animator: AnimatedSprite3D
@export var health_comp: Node

# Child States
@export var patrol: EnemyPatrol
@export var chase: EnemyChase
@export var attack: EnemyAttack
@export var death: EnemyDeath

# State Machine Instance
var machine: AltStateMachine = AltStateMachine.new()
# State property to interface easier with machine state
var state:
	get:
		return machine.current_state

var blackboard : Dictionary 

func _ready() -> void:
	# Populates blackboard and distributes it to all states
	blackboard = {"actor": self, "anim": animator}
	set_up_states()
	set_state(patrol)

func _process(delta: float) -> void:
	# Decision tree for switching states
	if health_comp._current_health <= 0:
		set_state(death)
	elif attack.attack_opp():
		set_state(attack)
	elif chase.player_spotted():
		set_state(chase)
	elif state.is_complete:
		if state is EnemyChase:
			set_state(patrol)
	
	# Runs logic for current_state branch
	state.update_branch(delta)
	
func _physics_process(delta: float) -> void:
	# Runs physics logic for current_state branch
	state.physics_update_branch(delta)
	
# Assigns blackboard to all state class nodes in enemy scene tree
func set_up_states() -> void:
	for descend in get_all_descendants(self):
		if descend is State:
			descend.init(blackboard)

# Returns array of all descendants in scene tree (used by set_up_states)
func get_all_descendants(node: Node) -> Array:
	var result: Array = []
	for child in node.get_children():
		result.append(child)
		result.append_array(get_all_descendants(child))
	return result
	
# Pass state transition request to state machine
func set_state(new_state: State, force_reset: bool = false) -> void:
	machine.set_state(new_state, force_reset)
