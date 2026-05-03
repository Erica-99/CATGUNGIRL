extends CharacterBody3D

@export_category("Component Nodes")
@export var animator: AnimatedSprite3D
@export var state_machine: StateMachine

@onready var health_comp = $HealthComponent
#@onready var gun_component = $GunComponent
@export var grenade: PackedScene

@export_category("Movement Variables")
@export var move_speed: float = 15
@export var slow_down_speed: float = 30
var facing: float

# Maybe this should move to the Scrub Gun
@export_category("Attack Variables")
@export var detected_player: bool = false
@export var gun_damage: float = 10
@export var gun_cd: float = 3
var gun_timer = 0

var blackboard: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Blackboard contains the information states will use
	blackboard = {
		# Actor for movement stats
		"actor": self,
		"anim": animator,
#		"gun_component": gun_component,
		"grenade": grenade,
		"move_speed": move_speed,
		"slow_down_speed": slow_down_speed,
	}
	# Initialise state machine with Scrub information
	state_machine.init(blackboard)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_detection_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		detected_player = true
		state_machine.on_child_transition(state_machine.current_state, "scrubchase")
		print("Player entered detection")
