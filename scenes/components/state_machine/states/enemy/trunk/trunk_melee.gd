extends State
class_name TrunkMelee

# Information gained from state machine
var actor: CharacterBody3D
var anim: AnimatedSprite3D
var direction: int
var target: CharacterBody3D
var xpos_distance_to_melee: float
var melee_stop_speed: float

var player_offset_position: Vector3

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	direction = blackboard["direction"]
	target = blackboard["target"]
	xpos_distance_to_melee = blackboard["xpos_distance_to_melee"]
	melee_stop_speed = blackboard["melee_stop_speed"]

func enter() -> void:
	print("Melee")
	# set initial target position - make it so it isnt reactive during this state - should just be aim for melee and miss if player moves
	direction = sign(target.global_position.x - actor.global_position.x)
	player_offset_position = target.global_position
	player_offset_position.x -= (xpos_distance_to_melee * direction)
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction = sign(player_offset_position.x - actor.global_position.x)
	actor.velocity.x = direction * melee_stop_speed
	
	if abs(player_offset_position.x - actor.global_position.x) < 3:
		actor.velocity.x = 0
		# start animation?
	
	actor.move_and_slide()

func _on_melee_range_body_exited(body: Node3D) -> void:
	transitioned.emit(self, "trunkchase")
