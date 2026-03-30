extends CharacterBody3D

@export var animator: AnimatedSprite3D

var machine: AltStateMachine
var state:
	get:
		return machine.state

var blackboard : Dictionary = {
	"actor": self,
	"animator": animator
	}

func _ready() -> void:
	set_up_instances()

func _process(delta: float) -> void:
	#add logic here to change child states
	
	
	
	
	state.update_branch(delta)
	
func _physics_process(delta: float) -> void:
	state.physics_update_branch(delta)
	
	
# gets all children states of scene and assigns blackboard
func set_up_instances() -> void:
	for child in get_children():
		if child is State:
			child.init(blackboard)
			
#pass state transition request to state machine
func set_state(new_state: State, force_reset: bool = false) -> void:
	machine.set_state(new_state, force_reset)
