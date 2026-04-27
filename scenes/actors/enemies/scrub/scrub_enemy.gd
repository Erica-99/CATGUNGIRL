extends CharacterBody3D

@export_category("Component Nodes")
@export var state_machine: StateMachine

@onready var health_comp = $HealthComponent
@onready var gun_component = $GunComponent
@export var grenade: PackedScene

@export_category("Movement Variables")
@export var move_speed: float = 15
@export var acceleration: float = 30
var facing: float

# Maybe this should move to the Scrub Gun
@export_category("Attack Variables")
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
		"gun_component": gun_component,
		"grenade": grenade,
	}
	# Initialise state machine with Scrub information
	state_machine.init(blackboard)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
