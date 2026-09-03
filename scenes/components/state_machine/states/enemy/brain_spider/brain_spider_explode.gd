extends State

var actor: BrainSpider
var explosion_timer: float = 0.0
var has_damaged: bool = false

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]

func enter() -> void:
	explosion_timer = 0.0
	has_damaged = false
	actor.velocity = Vector3.ZERO

func update(delta: float) -> void:
	if actor.is_dead:
		return
	
	if !has_damaged:
		has_damaged = true
		actor.damage_players_in_explosion_area()
	
	explosion_timer += delta
	
	if explosion_timer >= actor.explosion_duration:
		transitioned.emit(self, "brainspiderdeath")

func physics_update(_delta: float) -> void:
	actor.velocity = Vector3.ZERO
