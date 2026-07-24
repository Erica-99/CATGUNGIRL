extends State
class_name TrunkOutranged

# Information gained from state machine
var actor: CharacterBody3D
var anim: AnimatedSprite3D
var target: CharacterBody3D
var slow_down_speed: float

var past_player_pos: Vector3

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	target = blackboard["target"]

func enter() -> void:
	past_player_pos = target.global_position
	print("Out of range")
	# set missile firing to TRUE
	# ammo = 0? or keep reference over states?

func exit() -> void:
	pass
	# set missile firing to FALSE

func update(_delta: float) -> void:
	var direction = sign(target.global_position.x - actor.global_position.x)
	actor.facing = direction

func physics_update(delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, delta)
	
	if past_player_pos != target.global_position:
		past_player_pos = target.global_position
		
		if actor.can_take_step and len(actor.chase_range.get_overlapping_bodies()) != 0:
			transitioned.emit(self, "trunkchase")
	
	
	#anim.play("idle")
	actor.move_and_slide()

func _on_chase_range_body_entered(body: Node3D) -> void:
	transitioned.emit(self, "trunkchase")
