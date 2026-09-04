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
# power dive
var dive_cd: float
var dive_timer: float = 0
var gravity: float
var dive_launch_force: float
# shared route points
var convict_route_points: Array = []
var current_route_point: Node3D = null
var route_point_reached_distance: float = 1.0
var routing_to_dive_spot: bool = false

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
	convict_route_points = blackboard["convict_route_points"]

func enter() -> void:
	# TODO: update with more intricated targetting
	target = get_tree().get_nodes_in_group("player")[0] as CharacterBody3D
	actor.velocity = Vector3.ZERO
	if actor.action_pending:
		_start_cooldown()
	
	dive_timer = 0
	current_route_point = null
	routing_to_dive_spot = false

func _start_cooldown() -> void:
	await get_tree().create_timer(randf_range(attack_cooldown_min, attack_cooldown_max)).timeout
	attack_hitbox.find_child("*").set_deferred("disabled", false)
	actor.action_pending = false

# calculates target position in front of player on the convicts side
# stop_offset * -direction flips the offset to whichever side convict is coming from 
func _get_target_position() -> Vector3:
	return target.global_position + Vector3(stop_offset * -direction, 0, 0)
	
#find closest route point
func _pick_route_point() -> Node3D:
	if convict_route_points.is_empty():
		return null
	
	var closest_point: Node3D = null
	var closest_distance: float = INF
	
	for point in convict_route_points:
		if point == null:
			continue
		
		var distance: float = actor.global_position.distance_squared_to(point.global_position)
		
		if distance < closest_distance:
			closest_distance = distance
			closest_point = point
	
	return closest_point
	
func _has_power_dive_space() -> bool:
	var estimated_dive_height: float = (dive_launch_force * dive_launch_force) / (2.0 * gravity)
	return !actor.test_move(actor.global_transform, Vector3(0.0, estimated_dive_height, 0.0))

func physics_update(_delta: float) -> void:
	if actor.global_position.x > target.global_position.x:
		direction = -1
	elif actor.global_position.x < target.global_position.x:
		direction = 1
	
	var player_is_above: bool = actor.global_position.y < target.global_position.y
	var player_is_below: bool = actor.global_position.y > target.global_position.y + 1.0
	var can_power_dive: bool = actor.is_on_floor()
	
	if !can_power_dive:
		dive_timer = 0.0
		routing_to_dive_spot = false
		current_route_point = null
	elif player_is_below:
		dive_timer = 0.0
		routing_to_dive_spot = false
		current_route_point = null
	# add to dive timer while below target
	elif player_is_above:
		dive_timer += _delta
	else:
		dive_timer = 0
		
	var searching_for_dive_spot: bool = false
	# When below target for long enough, move to superjump state
	if can_power_dive and dive_timer > dive_cd:
		if _has_power_dive_space():
			current_route_point = null
			routing_to_dive_spot = false
			transitioned.emit(self, "convictpowerdive")
			return
		else:
			routing_to_dive_spot = true
			searching_for_dive_spot = true
	
	# offset target position
	var target_position = _get_target_position()
	var move_direction: float = 0.0
	var trying_to_run: bool = false
	var blocked_ahead: bool = false
	var using_route_point: bool = false
	
	# height/distance checks for superjump (UNCOMMENT TO TEST SUPERJUMP)
	#var height_difference = target.global_position.y - actor.global_position.y
	#var horizontal_difference = abs(actor.global_position.x - target.global_position.x)
	
	# check if convict is already in an acceptable position
	if (searching_for_dive_spot or routing_to_dive_spot) and !convict_route_points.is_empty():
		using_route_point = true

		if can_power_dive and _has_power_dive_space():
			current_route_point = null
			routing_to_dive_spot = false
			transitioned.emit(self, "convictpowerdive")
			return
		
		var reached_route_point: bool = current_route_point != null and abs(actor.global_position.x - current_route_point.global_position.x) <= route_point_reached_distance
		
		if current_route_point == null or reached_route_point:
			current_route_point = _pick_route_point()
		
		if current_route_point != null:
			move_direction = sign(current_route_point.global_position.x - actor.global_position.x)
			trying_to_run = true
			actor.velocity.x = move_toward(actor.velocity.x, chase_speed * move_direction, accel_speed * _delta)

	elif abs(actor.global_position.x - target_position.x) <= acceptable_distance:
		actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * _delta)
	
	else:
		move_direction = sign(target_position.x - actor.global_position.x)
		trying_to_run = true

		# Basic physics implementation 
		actor.velocity.x = move_toward(actor.velocity.x, chase_speed * move_direction, accel_speed * _delta)
		# move_toward shouldn't allow going over target value so this line is redundant
		# leaving it here just in case
		#actor.velocity.x = clamp(actor.velocity.x, -chase_speed, chase_speed)
		
	#check if convict is blocked by something
	if trying_to_run:
		blocked_ahead = actor.test_move(actor.global_transform, Vector3(move_direction * 0.4, 0.0, 0.0))
		
		if blocked_ahead and !using_route_point:
			routing_to_dive_spot = true
			current_route_point = null
	
	actor.apply_soft_collision(_delta)
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
