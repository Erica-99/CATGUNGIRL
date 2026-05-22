extends AnimatableBody3D

# set reference vars
@onready var elevator_start: Marker3D = $"../ElevatorStart"
@onready var elevator_end: Marker3D = $"../ElevatorEnd"

# set runtime vars
var was_ran: bool = false
var elevator_tween: Tween

# set constants
const ELEVATOR_SPEED: float = 3

func _ready() -> void:
	# connect up signals
	EventManager.start_elevator.connect(_elevator_start_sequence)

func _process(delta: float) -> void:
	pass

func _elevator_start_sequence():
	# run once (for now - if we want elevators to run multiple times ill have to change this)
	if !was_ran:
		elevator_tween = create_tween()
		# https://www.reddit.com/r/godot/comments/13ste37/tweenset_easetweenease_in_out_isnt_working_am_i/
		elevator_tween.set_trans(Tween.TRANS_SINE)
		elevator_tween.set_ease(Tween.EASE_IN_OUT)
		
		# start tween
		elevator_tween.tween_property(self, "global_position", elevator_end.global_position, ELEVATOR_SPEED)
		was_ran = false
