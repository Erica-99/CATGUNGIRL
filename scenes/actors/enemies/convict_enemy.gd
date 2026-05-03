extends CharacterBody3D
class_name ConvictEnemy

# Node References
@export var animator: AnimatedSprite3D
@export var health_comp: Node

# Child States
@export var patrol: EnemyPatrol
@export var engage: ConvictEngage
@export var death: EnemyDeath
@export var search: EnemySearch

@export_category("Anchors")
@export var anchor_1: Node3D
@export var anchor_2: Node3D

# State Machine Instance
var machine: AltStateMachine = AltStateMachine.new()
# State property to interface easier with machine state
var state:
	get:
		return machine.current_state

var blackboard : Dictionary 

func _ready() -> void:
	# Populates blackboard and distributes it to all states
	blackboard = {"actor": self, "anim": animator, "anchor_1": anchor_1, "anchor_2": anchor_2}
	set_up_states()
	set_state(patrol)

func _process(delta: float) -> void:
	# Decision tree for switching states
	if health_comp._current_health <= 0: # Death Condition
		set_state(death)
	elif engage.player_spotted(): # Enemy Aggro Condition
		set_state(engage)
	elif state.is_complete:
		if state is EnemySearch: # Enemy Patrol Condition
			set_state(patrol)
		if state is ConvictEngage: # Enemy Search Condition
			set_state(search)
		
	
	
	# Runs logic for current_state branch
	state.update_branch(delta)
	
	if velocity.x < 0:
		scale.x = -1
	elif velocity.x > 0:
		scale.x = 1
	
	
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
