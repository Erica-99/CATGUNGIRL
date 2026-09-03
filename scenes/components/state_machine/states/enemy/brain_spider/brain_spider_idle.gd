extends State

var actor: BrainSpider
var detection_area: Area3D

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	detection_area = blackboard["detection_area"]

func enter() -> void:
	actor.target = null
	actor.velocity.x = 0.0

func update(_delta: float) -> void:
	if actor.is_dying or actor.is_dead:
		return
	
	for body in detection_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			actor.target = body as CharacterBody3D
			transitioned.emit(self, "brainspiderchase")
			return

func physics_update(delta: float) -> void:
	if actor.is_dying or actor.is_dead:
		return
	
	if !actor.is_on_floor():
		actor.velocity.y -= actor.gravity * delta
	
	actor.velocity.x = move_toward(actor.velocity.x, 0.0, actor.acceleration * delta)
	actor.apply_soft_collision(delta)
	actor.move_and_slide()
