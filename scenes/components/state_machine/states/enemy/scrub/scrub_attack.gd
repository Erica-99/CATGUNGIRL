# Attack State: stand still and shoot Player in attack range

# Attack after being Alerted and Player is in range

# From Attack State the Scrub can transition into:
#   - Grenade, after a set time/condition, the scrub will throw a grenade
#   - Flee, if player gets too close, try to run away
#   - Chase, if player gets out of attack range, move into attack range

extends State
class_name ScrubAttack

# Information gained from state machine
var actor: CharacterBody3D
var anim: AnimatedSprite3D
var target: CharacterBody3D
var gun_component: Node3D
var slow_down_speed: float

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	target = blackboard["target"]
	gun_component = blackboard["gun_component"]
	slow_down_speed = blackboard["slow_down_speed"]

func enter() -> void:
	pass

func exit() -> void:
	gun_component._is_firing = false

func update(_delta: float) -> void:
	var direction = sign(target.global_position.x - actor.global_position.x)
	actor.facing = direction
	
	if actor.can_shoot.is_colliding():
		gun_component._is_firing = false
	else:
		gun_component._is_firing = true

func physics_update(delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * delta)
	#anim.play("idle")
	actor.move_and_slide()


func _on_att_range_area_3d_body_exited(body: Node3D) -> void:
	if !actor.is_dead:
		actor.in_attacking_range = true
		if actor.detected_player:
			transitioned.emit(self, "scrubchase")


func _on_flee_area_3d_body_entered(body: Node3D) -> void:
	if !actor.is_dead:
		transitioned.emit(self, "scrubflee")
