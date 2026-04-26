extends State
class_name EnemyMove

@onready var sprite_anims = $"../../../Visuals/AnimationPlayer"

@export var move_speed: float = 3.0
@export var anim: Animation

@export var animation = ''

var destination: Vector3
var threshold: float
var flat_dest: Vector3

var target_x: float

var body: CharacterBody3D
var animator: AnimatedSprite3D

func enter() -> void:
	# PLay Animation
	sprite_anims.play(animation)
	animator = blackboard["anim"]
	animator.modulate = Color(0.0, 0.5, 0.0, 1.0)
	# Set Body to Enemy
	body = blackboard["actor"]
	# Target destination adjusted to y of enemy 
	flat_dest = destination
	flat_dest.y = body.global_position.y

func update(_delta: float) -> void:
	# Checks if actor is in threshold range of destination
	if body.global_position.distance_to(flat_dest) <= threshold:
		is_complete = true

func physics_update(_delta: float) -> void:
	# Move enemy toward target
	var dir = (flat_dest - body.global_position).normalized()
	body.velocity.x = dir.x * move_speed
	body.velocity.z = dir.z * move_speed
	body.move_and_slide()
