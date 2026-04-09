extends CharacterBody3D
class_name ConvictEnemy

@export var animator: AnimatedSprite3D
@export var health_comp: Node

# Child States
@export var patrol: EnemyPatrol
@export var chase: EnemyChase
@export var attack: EnemyAttack
@export var death: EnemyDeath

var machine: AltStateMachine = AltStateMachine.new()
var state:
	get:
		return machine.current_state

var blackboard : Dictionary 

func _ready() -> void:
	blackboard = {"actor": self, "anim": animator}

	set_up_instances()
	set_state(patrol)

func _process(delta: float) -> void:
	
	if health_comp._current_health <= 0:
		set_state(death)
		pass
	elif attack.attack_opp():
		#set_state(attack)
		pass
	elif chase.player_spotted():
		set_state(chase)
	elif state.is_complete:
		if state is EnemyChase:
			set_state(patrol)
	# 
	#
	#
	
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
