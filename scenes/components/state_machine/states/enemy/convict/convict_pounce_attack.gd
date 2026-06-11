# separate attack state for pounce, basically same as hitconfirm

extends State

var actor: CharacterBody3D
var anim: AnimationPlayer
var slow_down_speed: float
var attack_hitbox: Area3D

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	slow_down_speed = blackboard["slow_down_speed"]
	attack_hitbox = blackboard["attack_hitbox"]

func enter() -> void:
	actor.action_pending = false
	anim.stop()
	# maybe pounce attack seperate anim?
	anim.play("Attack")
	attack_hitbox.find_child("*").set_deferred("disabled", false)

func physics_update(_delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * _delta)
	actor.move_and_slide()
	await anim.animation_looped
	attack_hitbox.find_child("*").set_deferred("disabled", true)
	actor.action_pending = true
	transitioned.emit(self, "convictchase")
