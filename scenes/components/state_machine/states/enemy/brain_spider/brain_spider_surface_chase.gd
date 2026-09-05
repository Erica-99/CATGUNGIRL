extends State

var actor: BrainSpider

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]

func enter() -> void:
	actor.velocity = Vector3.ZERO
	actor.laser.visible = false

func update(_delta: float) -> void:
	if actor.is_dying or actor.is_dead:
		return
	
	if actor.target == null or !is_instance_valid(actor.target):
		actor.target = blackboard["target"]
	
	if actor.has_line_of_sight():
		transitioned.emit(self, "brainspideraim")
		return

func physics_update(delta: float) -> void:
	if actor.is_dying or actor.is_dead:
		return
	
	if actor.target == null or !is_instance_valid(actor.target):
		actor.velocity = actor.velocity.move_toward(Vector3.ZERO, actor.acceleration * delta)
		actor.move_and_slide()
		return
	
	var surface_move_axis: Vector3 = actor.get_surface_move_axis()
	var target_offset: Vector3 = actor.target.global_position - actor.global_position
	var move_direction: float = sign(target_offset.dot(surface_move_axis))
	var target_velocity: Vector3 = surface_move_axis * move_direction * actor.move_speed
	
	actor.velocity = actor.velocity.move_toward(target_velocity, actor.acceleration * delta)
	actor.velocity += actor.get_surface_gravity_direction() * actor.gravity * delta
	actor.velocity.z = 0
	
	actor.apply_soft_collision(delta)
	actor.move_and_slide()
