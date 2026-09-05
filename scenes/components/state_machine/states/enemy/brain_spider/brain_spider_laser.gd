extends State

var actor: BrainSpider
var has_fired: bool = false

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]

func enter() -> void:
	has_fired = false
	actor.velocity = Vector3.ZERO

func update(_delta: float) -> void:
	if actor.is_dying or actor.is_dead:
		return
	
	if !has_fired:
		has_fired = true
		actor.fire_laser()
		actor.laser_cooldown_timer = actor.laser_cooldown
		transitioned.emit(self, "brainspideraim")

func physics_update(_delta: float) -> void:
	actor.velocity = Vector3.ZERO
