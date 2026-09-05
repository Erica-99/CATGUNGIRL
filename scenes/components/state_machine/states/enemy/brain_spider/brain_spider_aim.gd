extends State

var actor: BrainSpider
var aim_timer: float = 0.0
var lock_timer: float = 0.0
var aim_locked: bool = false

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]

func enter() -> void:
	aim_timer = 0.0
	lock_timer = 0.0
	aim_locked = false
	actor.velocity = Vector3.ZERO

func update(delta: float) -> void:
	if actor.is_dying or actor.is_dead:
		return
	
	if actor.target == null or !is_instance_valid(actor.target):
		actor.laser.visible = false
		transitioned.emit(self, "brainspidersurfacechase")
		return
	
	if !actor.has_line_of_sight():
		actor.laser.visible = false
		transitioned.emit(self, "brainspidersurfacechase")
		return
	
	if actor.laser_cooldown_timer > 0.0:
		actor.laser.visible = false
		actor.laser_cooldown_timer -= delta
		return
	
	actor.laser.visible = true
	
	if !aim_locked:
		actor.aim_laser()
		aim_timer += delta
		
		if aim_timer >= actor.laser_track_time:
			aim_locked = true
			lock_timer = 0.0
			
			actor.locked_laser_direction = actor.target.global_position - actor.laser_origin.global_position
			actor.locked_laser_direction.z = 0
			actor.locked_laser_direction = actor.locked_laser_direction.normalized()
		
		return
	
	var locked_angle: float = Vector2(actor.locked_laser_direction.x, actor.locked_laser_direction.y).angle()
	actor.laser_origin.global_rotation.z = locked_angle
	lock_timer += delta
	
	if lock_timer >= actor.laser_lock_time:
		transitioned.emit(self, "brainspiderlaser")

func physics_update(_delta: float) -> void:
	actor.velocity = Vector3.ZERO
