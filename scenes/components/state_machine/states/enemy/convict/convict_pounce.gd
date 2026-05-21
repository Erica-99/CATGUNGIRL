# Pounce State: when target is in range, jump at them to attack.
#    After the jump is a cooldown where the convict faceplants if they miss.

extends State

var actor: CharacterBody3D
var anim: AnimatedSprite3D
var jump_force: float
var chase_speed: float
var slow_down_speed: float

var target: CharacterBody3D
var direction: int
# Check if jumped starts false
var has_jumped: bool = false

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	jump_force = blackboard["jump_force"]
	chase_speed = blackboard["chase_speed"]
	slow_down_speed = blackboard["slow_down_speed"]

# When changing to Pounce, lock in target and direction to the target
func enter() -> void:
	# Update with better targetting system
	target = get_tree().get_nodes_in_group("player")[0] as CharacterBody3D
	if actor.global_position > target.global_position:
		direction = -1
	elif actor.global_position < target.global_position:
		direction = 1

# Jumping force should only be added once, after convict lands on the ground they do a faceplant
func physics_update(_delta: float) -> void:
	# If convict hasn't jumped and is on the floor, do the jump forward
	if actor.is_on_floor():
		if !has_jumped:
			pounce()
		# If they are on the floor after their jump go into a faceplant slide
		else:
			actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * _delta)
			faceplant()
	
	actor.move_and_slide()

func exit() -> void:
	# Reset jump check
	has_jumped = false

func pounce():
	# Set velocity to zero to make pounce consistent
	actor.velocity = Vector3.ZERO
	actor.velocity.x += chase_speed * direction
	actor.velocity.y += jump_force
	has_jumped = true

# Similar to HitConfirm, the cooldown time is connected to a faceplanting animation
# TODO: change to anim.animation_finished when non-looping animation is implemented
func faceplant():
	#anim.play("Faceplant")
	await anim.animation_looped
	# Basic implementation to see if enemy has come to a complete stop
	if actor.velocity.x == 0:
		transitioned.emit(self, "convictchase")

func _on_attack_hitbox_body_entered(body: Node3D) -> void:
	actor.target_in_hitbox = true
	transitioned.emit(self, "convicthitconfirm")
