extends State
class_name EnemyIdle

@export var idle_min_time: float
@export var idle_max_time: float
var idle_duration: float
var idle_timer: float

# On Enter, sets a random duration to pause for and sets timer to 0. Sets actor velocity to 0
func enter() -> void:
	idle_duration = randf_range(idle_min_time, idle_max_time)
	idle_timer = 0.0
	
	var body: CharacterBody3D = blackboard["actor"]
	body.velocity = Vector3.ZERO
	pass

# Ticks up timer, and transitions to move when time expires
func update(_delta: float) -> void:
	
	idle_timer += _delta

	# Wait until the random duration passes
	if idle_timer >= idle_duration:
		is_complete = true
	pass
