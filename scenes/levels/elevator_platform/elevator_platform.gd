extends AnimatableBody3D

@onready var elevator_start: Marker3D = $"../ElevatorStart"
@onready var elevator_end: Marker3D = $"../ElevatorEnd"

var active: bool = false
var elevator_tween: Tween

const ELEVATOR_SPEED: float = 3

func _ready() -> void:
	EventManager.start_elevator.connect(_elevator_start_sequence)

func _process(delta: float) -> void:
	if active:
		if elevator_tween:
			elevator_tween.kill()
			
		elevator_tween = create_tween()
		elevator_tween.tween_property(self, "global_position", elevator_end, ELEVATOR_SPEED)

func _elevator_start_sequence():
	active = true
