extends State
class_name EnemyAlert

# Animation controller
@onready var sprite_anims = $"../../../Visuals/AnimationPlayer"

@export var alert_duration: float
@export var animation = ''

var alert_timer: float

var body: CharacterBody3D
var animator: AnimatedSprite3D

func enter() -> void:
	# Play Alert Animation
	sprite_anims.play(animation)
	
	# Reset Alert Timer
	alert_timer = 0
	
	# Stop Movement
	body = blackboard["actor"]
	body.velocity = Vector3.ZERO
	body.move_and_slide()
	
func update(_delta: float) -> void:
	alert_timer += _delta
	if alert_timer >= alert_duration:
		is_complete = true
	pass
