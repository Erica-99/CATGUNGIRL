extends State
class_name TrunkChase

# Information gained from state machine
var actor: CharacterBody3D
var anim: AnimatedSprite3D
var target: CharacterBody3D
var chase_speed: float

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	target = blackboard["target"]
	chase_speed = blackboard["chase_speed"]

func enter() -> void:
	print("Chasing")

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction = sign(target.global_position.x - actor.global_position.x)
	actor.facing = direction
	#anim.play("chase")
	
	#actor.velocity.x += direction * chase_speed * delta
	#actor.velocity.x = clamp(actor.velocity.x, -chase_speed, chase_speed)
	
	actor.velocity.x = move_toward(actor.velocity.x, 0, delta)
	
	actor.move_and_slide()

func _on_chase_range_body_exited(body: Node3D) -> void:
	transitioned.emit(self, "trunkoutranged")

func _on_melee_range_body_entered(body: Node3D) -> void:
	transitioned.emit(self, "trunkmelee")
