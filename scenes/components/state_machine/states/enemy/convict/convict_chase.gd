# Chase State: Run at the player

# For Convict: when coming in contact with the player
#    do attack animation and deactivate attack hitbox

# For Scrub: when in attack range, shoot at player

extends State

var actor: CharacterBody3D
var anim: AnimatedSprite3D
var chase_speed: float
var accel_speed: float
var direction: int

var target: CharacterBody3D

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	direction = blackboard["direction"]
	chase_speed = blackboard["chase_speed"]
	accel_speed = blackboard["accel_speed"]

func enter() -> void:
	# TODO: update with more intricated targetting
	target = get_tree().get_nodes_in_group("player")[0] as CharacterBody3D
	actor.velocity = Vector3.ZERO

func physics_update(_delta: float) -> void:
	if actor.global_position > target.global_position:
		direction = -1
	elif actor.global_position < target.global_position:
		direction = 1
	
	anim.play("Run")
	
	# Basic physics implementation
	actor.velocity.x = move_toward(actor.velocity.x, chase_speed * direction, accel_speed * _delta)
	actor.velocity.x = clamp(actor.velocity.x, -chase_speed, chase_speed)
	actor.move_and_slide()

func _on_attack_hitbox_body_entered(body: Node3D) -> void:
	# To track if the target remains in hitbox
	actor.target_in_hitbox = true
	transitioned.emit(self, "convicthitconfirm")

func _on_pounce_range_3d_body_entered(body: Node3D) -> void:
	transitioned.emit(self, "convictpounce")
