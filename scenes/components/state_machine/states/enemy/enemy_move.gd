extends State
class_name EnemyMove

var direction: int = 1
var speed: float = 3.0
var move_distance: float = 5.0

var target_x: float

func enter() -> void:
	# flip patrol direction
	direction *= -1
	
	# flips sprite visual
	var actor: CharacterBody3D = blackboard["actor"]
	actor.scale *= -1
	
	# set target position
	
	
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	# check if target threshold is reached
	# set state isComplete to true
	pass


func physics_update(_delta: float) -> void:
	# move enemy toward target
	pass
