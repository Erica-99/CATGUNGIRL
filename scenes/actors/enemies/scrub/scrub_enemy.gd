extends CharacterBody3D

@export_category("Component Nodes")
@export var animator: AnimatedSprite3D
@export var state_machine: StateMachine

@onready var health_comp = $HealthComponent
@export var gun_component: Node3D
@export var grenade: PackedScene

@export_category("Movement Variables")
@export var move_speed: float = 10
@export var slow_down_speed: float = 30
var facing: float

# Maybe this should move to the Scrub Gun
@export_category("State Controlling Variables")
@export var detected_player: bool = false
var in_attacking_range: bool

var blackboard: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Blackboard contains the information states will use
	blackboard = {
		# Actor for movement stats
		"actor": self,
		"anim": animator,
		"gun_component": gun_component,
		"grenade": grenade,
		"move_speed": move_speed,
		"slow_down_speed": slow_down_speed,
	}
	# Initialise state machine with Scrub information
	state_machine.init(blackboard)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# When player enters detection range, move to attack
# For a possible specific case, if they are in detection but
# not attack range move to chase.
# TODO: Improve by utilising more detection logic than just an area
func _on_detection_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if detected_player == false:
			detected_player = true
			print("Player entered detection area")
			if in_attacking_range:
				state_machine.on_child_transition(state_machine.current_state, "scrubattack")
				print("Attacking Player")
			else:
				state_machine.on_child_transition(state_machine.current_state, "scrubchase")

# When player enters attack range, check off that theyre in range
# If player has been detected, move to attack state
func _on_att_range_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		in_attacking_range = true
		if detected_player:
			state_machine.on_child_transition(state_machine.current_state, "scrubattack")
			print("Attacking Player")

# When player leaves attack range, check of that they're out of range
# If they have been detected, move to chase
func _on_att_range_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		in_attacking_range = true
		if detected_player:
			state_machine.on_child_transition(state_machine.current_state, "scrubchase")
			print("Chasing Player")

# When player enters flee range, move to flee
func _on_flee_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		state_machine.on_child_transition(state_machine.current_state, "scrubflee")
		print("Fleeing Player")

# When player exits flee range, move to attack
# TODO: Improve flee logic so that Scrub tries to make distance/
#    stops fleeing if they are blocked.
func _on_flee_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		state_machine.on_child_transition(state_machine.current_state, "scrubattack")
