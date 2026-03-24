extends State
class_name EnemyIdle

var idle_duration: float
var idle_timer: float


# On Enter, sets a random duration to pause for and sets timer to 0
func enter() -> void:
	idle_duration = randf_range(2.0, 5.0)
	idle_timer = 0.0
	pass


func exit() -> void:
	pass

# Ticks up timer, and transitions to move when time expires
func update(_delta: float) -> void:
	
	idle_timer += _delta

	# Wait until the random duration passes
	if idle_timer >= idle_duration:
		transitioned.emit(self, "enemymove")

	pass


func physics_update(_delta: float) -> void:
	pass
