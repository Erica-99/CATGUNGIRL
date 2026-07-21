extends State
class_name TrunkPatrol

var actor: CharacterBody3D
var anim: AnimatedSprite3D
var target: CharacterBody3D
var patrol_speed: float
var min_patrol_time: float
var max_patrol_time: float
var direction: int
var patrol_timer: Timer
var elapsed_direction_switch: float

var patrol_track: float = 0 # timer tracker

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	target = blackboard["target"]
	direction = blackboard["direction"]
	patrol_speed = blackboard["patrol_speed"]
	min_patrol_time = blackboard["min_patrol_time"]
	max_patrol_time = blackboard["max_patrol_time"]
	elapsed_direction_switch = blackboard["elapsed_direction_switch"]
	
	patrol_timer = Timer.new()
	patrol_timer.one_shot = false
	patrol_timer.timeout.connect(_switch_to_idle)
	add_child(patrol_timer)

func enter() -> void:
	print("Patrolling")
	patrol_timer.wait_time = randf_range(min_patrol_time, max_patrol_time)
	patrol_timer.start()

func exit() -> void:
	patrol_timer.stop()

func update(_delta: float) -> void:
	patrol_track += _delta
	if patrol_track >= elapsed_direction_switch:
		actor.velocity = Vector3.ZERO
		direction *= -1
		patrol_track = 0

func physics_update(delta: float) -> void:
	#direction = sign(actor.velocity.x)
	actor.facing = direction
	actor.velocity.x = move_toward(actor.velocity.x, 0, delta)
	
	#actor.velocity.x += direction * patrol_speed * delta
	#actor.velocity.x = clamp(actor.velocity.x, -patrol_speed, patrol_speed)
	
	actor.move_and_slide()

func _on_detection_range_body_entered(body: Node3D) -> void:
	transitioned.emit(self, "trunkchase")

func _switch_to_idle():
	transitioned.emit(self, "trunkidle")
