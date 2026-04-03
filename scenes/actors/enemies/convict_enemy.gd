extends CharacterBody3D

@export var animator: AnimatedSprite3D

# Child States
@export var patrol: EnemyPatrol

var machine: AltStateMachine = AltStateMachine.new()
var state:
	get:
		return machine.current_state

var blackboard : Dictionary = {
	"actor": self,
	"animator": animator
	}

func _ready() -> void:
	set_up_instances()
	set_state(patrol)

func _process(delta: float) -> void:
	#add logic here to change child states
	
	
	
	
	state.update_branch(delta)
	
func _physics_process(delta: float) -> void:
	state.physics_update_branch(delta)
	
	
# assigns blackboard to all state class nodes in enemy scene tree
func set_up_instances() -> void:
	for descend in get_all_descendants(self):
		if descend is State:
			descend.init(blackboard)
			
#pass state transition request to state machine
func set_state(new_state: State, force_reset: bool = false) -> void:
	machine.set_state(new_state, force_reset)
	
# returns array of all descendants in scene tree
func get_all_descendants(node: Node) -> Array:
	var result: Array = []
	for child in node.get_children():
		result.append(child)
		result.append_array(get_all_descendants(child))
	return result
	
#
