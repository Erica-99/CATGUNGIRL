# Chase State: Run at the player

# For Convict: when coming in contact with the player
#    do attack animation and deactivate attack hitbox

# For Scrub: when in attack range, shoot at player

extends State

var actor: CharacterBody3D
var anim: AnimatedSprite3D
var chase_speed: float
var accel_speed: float
var slow_down_speed: float
var direction: int
# distance from target to stop at
var stop_offset: float = 0.9
# acceptable distance
var acceptable_distance: float = 0.9
var target: CharacterBody3D


func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	direction = blackboard["direction"]
	chase_speed = blackboard["chase_speed"]
	accel_speed = blackboard["accel_speed"]
	slow_down_speed = blackboard["slow_down_speed"]

func enter() -> void:
	# TODO: update with more intricated targetting
	target = get_tree().get_nodes_in_group("player")[0] as CharacterBody3D
	actor.velocity = Vector3.ZERO

	# calculates target position in front of player on the convicts side
	# stop_offset * -direction flips the offset to whichever side convict is coming from 
func _get_target_position() -> Vector3:
	return target.global_position + Vector3(stop_offset * -direction, 0, 0)

func physics_update(_delta: float) -> void:
	if actor.global_position.x > target.global_position.x:
		direction = -1
	elif actor.global_position.x < target.global_position.x:
		direction = 1
	
	# offset target position
	var target_position = _get_target_position()
	
	# height/distance checks for superjump (UNCOMMENT TO TEST SUPERJUMP)
	#var height_difference = target.global_position.y - actor.global_position.y
	#var horizontal_difference = abs(actor.global_position.x - target.global_position.x)
	
	# check if convict is already in an acceptable position
	if abs(actor.global_position.x - target_position.x) <= acceptable_distance:
		# OLD (slidey stop) swap with instant swap if we want sharper movement
		actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * _delta)
		# NEW instant stop 
		#actor.velocity.x = 0.0
		anim.play("Idle")
		
		#TODO: proper superjump trigger (UNCOMMENT TO TEST SUPERJUMP)
		#if height_difference > 3.0 and horizontal_difference <= 2.5:
			#transitioned.emit(self, "convictsuperjump")
			#print("transitioning to convictsuperjump")
	
	else:
		var move_direction = sign(target_position.x - actor.global_position.x)
		
		# print to check differences for tuning superjump values
		# print("height: ", height_difference, " horizontal: ", horizontal_difference)
		
		# TODO: proper superjump trigger (UNCOMMENT TO TEST SUPERJUMP)
		#if height_difference > 3.0 and horizontal_difference <= 2.5:
			#transitioned.emit(self, "convictsuperjump")
			#print("transitioning to convictsuperjump")
		
		# Basic physics implementation 
		actor.velocity.x = move_toward(actor.velocity.x, chase_speed * move_direction, accel_speed * _delta)
		# move_toward shouldn't allow going over target value so this line is redundant
		# leaving it here just in case
		#actor.velocity.x = clamp(actor.velocity.x, -chase_speed, chase_speed)
		
		anim.play("Run")
		
	actor.move_and_slide()

func _on_attack_hitbox_body_entered(body: Node3D) -> void:
	# To track if the target remains in hitbox
	actor.target_in_hitbox = true
	transitioned.emit(self, "convicthitconfirm")

func _on_pounce_range_3d_body_entered(body: Node3D) -> void:
	transitioned.emit(self, "convictpounce")
	
