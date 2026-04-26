extends State
class_name EnemyPatrol

# Child States
@export var move: EnemyMove
@export var idle: EnemyIdle

# Exported Patrol Anchors (destinations to patrol between
@export var left_anchor: Node3D
@export var right_anchor: Node3D

# Thresholdd Variables (used to add variation to patrol distance)
@export var threshold_limit: float

func enter() -> void:
	go_to_next_destination()

func update(_delta: float) -> void:
	#switch back and forth betwween move and idle
	if child_state is EnemyMove and child_state.is_complete:
		set_state(idle)
	elif child_state is EnemyIdle and child_state.is_complete:
		go_to_next_destination()

func go_to_next_destination() -> void:
	var a1: Vector3 = left_anchor.global_position
	var a2: Vector3 = right_anchor.global_position
	# Switches Target Position
	if move.destination == a1:
		move.destination = a2
	else:
		move.destination = a1
	# Sets move threshold (random variation)
	move.threshold = randf_range(0.1, threshold_limit)
	set_state(move)
	pass
