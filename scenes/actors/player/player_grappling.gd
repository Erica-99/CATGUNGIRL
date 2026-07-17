extends State
class_name PlayerAbility

signal end_ability

var actor: CharacterBody3D
var input_component: InputComponent

@export var grapple_component: GrappleComponent

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	input_component = blackboard["input_component"]
	
	end_ability.connect(_end_ability)

func enter() -> void:
	var current_ability: Ability = blackboard["equipped_ability"]
	current_ability.initialise(self, blackboard)
	
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	var current_input_state = input_component.get_input_state()
	
	if current_input_state["jumping"]:
		grapple_component.early_release_grapple.emit()
		transitioned.emit(self, "playerjump")
	

func physics_update(_delta: float) -> void:
	actor.move_and_slide()


func _end_ability() -> void:
	transitioned.emit(self, "PlayerIdle")
