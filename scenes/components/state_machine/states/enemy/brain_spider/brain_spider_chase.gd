extends State

var actor: BrainSpider
var detonation_area: Area3D
var target: CharacterBody3D
var anim: AnimationPlayer

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	anim = blackboard["anim"]
	actor = blackboard["actor"]
	detonation_area = blackboard["detonation_area"]
	target = blackboard["target"]

func enter() -> void:
	if actor.target == null:
		actor.target = target

func update(_delta: float) -> void:
	if actor.is_dying or actor.is_dead:
		return
	
	if actor.target == null or !is_instance_valid(actor.target):
		return
	
	if detonation_area.get_overlapping_bodies().has(actor.target):
		transitioned.emit(self, "brainspiderexplode")
		return

func physics_update(delta: float) -> void:
	if actor.is_dying or actor.is_dead:
		return
	
	if !actor.is_on_floor():
		actor.velocity.y -= actor.gravity * delta
	
	if actor.target == null or !is_instance_valid(actor.target):
		actor.velocity.x = move_toward(actor.velocity.x, 0.0, actor.acceleration * delta)
		actor.apply_soft_collision(delta)
		anim.play("Scurry")
		actor.move_and_slide()
		return
	
	var move_direction: float = sign(actor.target.global_position.x - actor.global_position.x)
	actor.update_surface_check(Vector3.RIGHT, move_direction, Vector3.DOWN)
	
	if move_direction != 0.0:
		actor.brain_spider_visuals.face_direction(move_direction)
		
		if actor.can_take_step:
			actor.velocity.x = move_toward(actor.velocity.x, move_direction * actor.move_speed, actor.acceleration * delta)
		else:
			actor.velocity.x = 0.0
	
	actor.apply_soft_collision(delta)
	
	if !actor.can_take_step:
		actor.velocity.x = 0.0
	
	actor.move_and_slide()
