extends State
class_name TrunkChase

# Information gained from state machine
var actor: CharacterBody3D
var anim: AnimatedSprite3D
var animation_manager: AnimationPlayer
var target: CharacterBody3D
var chase_speed: float
var xpos_distance_vert_offset: float
var vert_threshold: float

var reached_offset: bool = false
signal reached_chase_offset(status: bool)

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	animation_manager = blackboard["animation_manager"]
	target = blackboard["target"]
	chase_speed = blackboard["chase_speed"]
	xpos_distance_vert_offset = blackboard["xpos_distance_vert_offset"]
	vert_threshold = blackboard["vert_threshold"]

func enter() -> void:
	reached_offset = false
	#print("Chasing")

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction = sign(target.global_position.x - actor.global_position.x)
	actor.facing = direction
	
	var new_offset_check: bool
	
	if abs(target.global_position.y - actor.global_position.y) > vert_threshold:
		var aimed_x_offset = target.global_position
		aimed_x_offset.x -= (xpos_distance_vert_offset * direction)
		if abs(aimed_x_offset.x - actor.global_position.x) < xpos_distance_vert_offset:
			actor.velocity.x = 0.0
			animation_manager.stop()
			new_offset_check = true
		else:
			new_offset_check = false
	else:
		new_offset_check = false
		
	if new_offset_check != reached_offset:
		reached_chase_offset.emit(new_offset_check)
		reached_offset = new_offset_check
		
		if reached_offset:
			actor.outranged_timer.start()
		else:
			actor.outranged_timer.stop()
	
	#anim.play("chase")
	
	#actor.velocity.x += direction * chase_speed * delta
	#actor.velocity.x = clamp(actor.velocity.x, -chase_speed, chase_speed)
	
	actor.velocity.x = move_toward(actor.velocity.x, 0, delta)
	
	actor.move_and_slide()

func _on_chase_range_body_exited(body: Node3D) -> void:
	transitioned.emit(self, "trunkoutranged")

func _on_melee_range_body_entered(body: Node3D) -> void:
	transitioned.emit(self, "trunkmelee")
