extends State
class_name PlayerDash

var actor: CharacterBody3D
var dash_timer: Timer

var dash_dir: float = 0.0
var dash_time_left: float = 0.0
var dash_speed: float = 0.0

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	dash_timer = blackboard["dash_timer"]
	
func enter() -> void:
	dash_dir = blackboard.get("dash_dir", 0.0)
	if dash_dir == 0.0:
		dash_dir = actor.facing
	if dash_dir == 0.0:
		dash_dir = 1.0
		
	dash_time_left = actor.dash_duration
	var duration: float = max(actor.dash_duration, 0.01)
	dash_speed = actor.dash_distance / duration
	
	#override horizontal momentum (edit later)
	actor.velocity.x = dash_dir * dash_speed
	if actor.dash_kill_movement:
		actor.velocity.y = 0.0
		
	dash_timer.start()
	
	if not actor.is_on_floor():
		blackboard["can_air_dash"] = false
		
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	dash_time_left -= _delta
	#(also edit later)
	if actor.dash_kill_movement:
		actor.velocity.y = 0.0
	elif not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * _delta

	actor.velocity.x = dash_dir * dash_speed
	actor.move_and_slide()
	
	if dash_time_left <= 0.0:
		if actor.is_on_floor():
			if actor.velocity.x == 0:
				transitioned.emit(self, "playeridle")
			else:
				transitioned.emit(self, "playermove")
		else:
			transitioned.emit(self, "playerfall")
