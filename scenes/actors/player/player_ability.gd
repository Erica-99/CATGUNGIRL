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
	var current_ability: Ability = blackboard["gun_holder"].current_gun.ability
	if current_ability == null:
		# I know this is awful I just can't come up with any better way of making it a one-shot input.
		input_component._ability_held = false
		
		_end_ability()
	else:
		current_ability.initialise(self, blackboard)
	
		# I know this is awful I just can't come up with any better way of making it a one-shot input.
		input_component._ability_held = false

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	actor.move_and_slide()


func _end_ability() -> void:
	transitioned.emit(self, "PlayerIdle")
