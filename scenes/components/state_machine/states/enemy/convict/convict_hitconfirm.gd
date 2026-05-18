# When Convict's attack hitbox collides with the target, they pause,
# do their attack animation.

extends State

var actor: CharacterBody3D
var anim: AnimatedSprite3D
var slow_down_speed: float
var attack_hitbox: Area3D

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	slow_down_speed = blackboard["slow_down_speed"]
	attack_hitbox = blackboard["attack_hitbox"]

func enter() -> void:
	#Allow for animation interrupts if a target jumps onto them while in their attack anim
	anim.stop()
	anim.play("Attack")

# The time that the Convict stops for after an attack is determined by their attack anim
func physics_update(_delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * _delta)
	actor.move_and_slide()
	await anim.animation_looped
	if actor.target_in_hitbox:
		transitioned.emit(self, "convicthitconfirm")
	else:
		transitioned.emit(self, "convictchase")
