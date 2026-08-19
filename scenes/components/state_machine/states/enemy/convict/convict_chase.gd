# Chase State: Run at the player

# For Convict: when coming in contact with the player
#    do attack animation and deactivate attack hitbox

# For Scrub: when in attack range, shoot at player

extends State

var actor: CharacterBody3D
var anim: AnimationPlayer
var chase_speed: float
var accel_speed: float
var slow_down_speed: float
var direction: int
# distance from target to stop at
var stop_offset: float = 0.9
# acceptable distance
var acceptable_distance: float = 0.9
var target: CharacterBody3D
# attack cooldown
var attack_hitbox: Area3D
var attack_cooldown_min: float
var attack_cooldown_max: float
# dive
var dive_cd: float
var dive_timer: float = 0
var gravity: float
var dive_launch_force: float


func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	direction = blackboard["direction"]
	chase_speed = blackboard["chase_speed"]
	accel_speed = blackboard["accel_speed"]
	slow_down_speed = blackboard["slow_down_speed"]
	attack_hitbox = blackboard["attack_hitbox"]
	attack_cooldown_min = blackboard["attack_cooldown_min"]
	attack_cooldown_max = blackboard["attack_cooldown_max"]
	dive_cd = blackboard["dive_cd"]
	gravity = blackboard["gravity"]
	dive_launch_force = blackboard["dive_launch_force"]

func enter() -> void:
	# TODO: update with more intricated targetting
	target = get_tree().get_nodes_in_group("player")[0] as CharacterBody3D
	actor.velocity = Vector3.ZERO
	if actor.action_pending:
		_start_cooldown()
	
	dive_timer = 0

func _start_cooldown() -> void:
	await get_tree().create_timer(randf_range(attack_cooldown_min, attack_cooldown_max)).timeout
	attack_hitbox.find_child("*").set_deferred("disabled", false)
	actor.action_pending = false

# calculates target position in front of player on the convicts side
# stop_offset * -direction flips the offset to whichever side convict is coming from 
func _get_target_position() -> Vector3:
	return target.global_position + Vector3(stop_offset * -direction, 0, 0)

func physics_update(_delta: float) -> void:
	if actor.global_position.x > target.global_position.x:
		direction = -1
	elif actor.global_position.x < target.global_position.x:
		direction = 1
	
	# While beneath target, add to super jump cooldown
	if actor.global_position.y < target.global_position.y:
		dive_timer += _delta
	else:
		dive_timer = 0
	
	# When below target for long enough, move to superjump state
	if dive_timer > dive_cd:
		var estimated_dive_height := (dive_launch_force * dive_launch_force) / (2.0 * gravity)
		var has_space_above := !actor.test_move(actor.global_transform, Vector3(0.0, estimated_dive_height, 0.0))
		
		if has_space_above:
			transitioned.emit(self, "convictpowerdive")
	
	# offset target position
	var target_position = _get_target_position()
	var move_direction: float = 0.0
	var trying_to_run: bool = false
	var blocked_ahead: bool = false
	
	# height/distance checks for superjump (UNCOMMENT TO TEST SUPERJUMP)
	#var height_difference = target.global_position.y - actor.global_position.y
	#var horizontal_difference = abs(actor.global_position.x - target.global_position.x)
	
	# check if convict is already in an acceptable position
	if abs(actor.global_position.x - target_position.x) <= acceptable_distance:
		# OLD (slidey stop) swap with instant swap if we want sharper movement
		actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * _delta)
		# NEW instant stop 
		#actor.velocity.x = 0.0
		
		#TODO: proper superjump trigger (UNCOMMENT TO TEST SUPERJUMP)
		#if height_difference > 3.0 and horizontal_difference <= 2.5:
			#transitioned.emit(self, "convictsuperjump")
			#print("transitioning to convictsuperjump")
	
	else:
		move_direction = sign(target_position.x - actor.global_position.x)
		trying_to_run = true
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
		
	#check if convict is blocked by something
	if trying_to_run:
		blocked_ahead = actor.test_move(actor.global_transform, Vector3(move_direction * 0.4, 0.0, 0.0))
		
	actor.move_and_slide()
	
	if !trying_to_run or blocked_ahead:
		anim.play("Idle")
	else:
		anim.play("Run")
	
	## Attempt to manually trigger stun to test things
	#if Input.is_action_pressed("ui_left"):
		#transitioned.emit(self, "convictstun")

func _on_attack_hitbox_body_entered(body: Node3D) -> void:
	# To track if the target remains in hitbox
	actor.target_in_hitbox = true
	if actor.action_pending:
		return
	transitioned.emit(self, "convicthitconfirm")

func _on_pounce_range_3d_body_entered(body: Node3D) -> void:
	if actor.action_pending:
		return
	transitioned.emit(self, "convictpounce")
