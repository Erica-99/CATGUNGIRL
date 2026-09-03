extends State

var actor: BrainSpider
var death_timer: float = 0.0

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]

func enter() -> void:
	death_timer = 0.0
	actor.is_dying = true
	actor.velocity = Vector3.ZERO

func update(delta: float) -> void:
	if actor.is_dead:
		return
	
	death_timer += delta
	
	if death_timer >= actor.death_duration:
		actor.die()

func physics_update(delta: float) -> void:
	if actor.is_dead:
		return
	
	if !actor.is_on_floor():
		actor.velocity.y -= actor.gravity * delta
	
	actor.velocity.x = 0.0
	actor.move_and_slide()
