# Patrol moves to Chase

extends State
class_name ScrubPatrol

var actor: CharacterBody3D
var anim: AnimationPlayer
var target: CharacterBody3D
var patrol_speed: float
var direction: int

var patrol_timer: float = 4 # time in seconds that enemy walks for
var patrol_track: float = 0 # timer tracker

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	target = blackboard["target"]
	direction = blackboard["direction"]
	patrol_speed = blackboard["patrol_speed"]

func update(_delta: float) -> void:
	patrol_track += _delta
	if patrol_track >= patrol_timer:
		actor.velocity = Vector3.ZERO
		direction *= -1
		patrol_track = 0

func physics_update(delta: float) -> void:
	#direction = sign(actor.velocity.x)
	actor.facing = direction
	
	actor.velocity.x += direction * patrol_speed * delta
	actor.velocity.x = clamp(actor.velocity.x, -patrol_speed, patrol_speed)
	
	actor.move_and_slide()

func _on_detection_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		transitioned.emit(self, "scrubchase")

#func _on_detection_area_3d_body_entered(body):
	#if body.is_in_group("player"):
		#transitioned.emit(self, "scrubchase")


func _on_flee_area_3d_body_entered(body: Node3D) -> void:
	if !actor.is_dead:
		transitioned.emit(self, "scrubflee")
