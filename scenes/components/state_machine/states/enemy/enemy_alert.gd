extends State
class_name EnemyAlert

@export var alert_duration: float

var alert_timer: float

var body: CharacterBody3D
var animator: AnimatedSprite3D

func enter() -> void:
	# Play Alert Animation
	animator = blackboard["anim"]
	animator.modulate = Color(0.5, 0.0, 0.0, 1.0)
	
	# Stop Movement
	body = blackboard["actor"]
	body.velocity = Vector3.ZERO
	body.move_and_slide()
	
func update(_delta: float) -> void:
	alert_timer += _delta
	if alert_timer >= alert_duration:
		is_complete = true
	pass
