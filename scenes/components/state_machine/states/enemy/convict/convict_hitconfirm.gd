# When Convict's attack hitbox collides with the target, they pause,
# do their attack animation.

extends State

var actor: CharacterBody3D
var anim: AnimatedSprite3D
var slow_down_speed: float
var attack_hitbox: Area3D
var hit_deceleration: float
var is_on_cooldown: bool = false

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	slow_down_speed = blackboard["slow_down_speed"]
	attack_hitbox = blackboard["attack_hitbox"]
	hit_deceleration = blackboard["hit_deceleration"]

func enter() -> void:
	is_on_cooldown = false
	actor.action_pending = false
	#Allow for animation interrupts if a target jumps onto them while in their attack anim
	anim.stop()
	anim.play("Attack")
	attack_hitbox.find_child("*").set_deferred("disabled", false)

# The time that the Convict stops for after an attack is determined by their attack anim
func physics_update(_delta: float) -> void:
	# hit deceleration makes stopping almost instant
	actor.velocity.x = move_toward(actor.velocity.x, 0, hit_deceleration * _delta)
	actor.move_and_slide()
	await anim.animation_looped
	if is_on_cooldown:
		return
	is_on_cooldown = true
	attack_hitbox.find_child("*").set_deferred("disabled", true)
	actor.action_pending = true
	transitioned.emit(self, "convictchase")
