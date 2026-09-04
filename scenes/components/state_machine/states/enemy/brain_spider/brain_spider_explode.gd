extends State

var actor: BrainSpider
var has_damaged: bool = false

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]

func enter() -> void:
	has_damaged = false
	actor.velocity = Vector3.ZERO
	actor.show_explosion_effect()

func update(_delta: float) -> void:
	if actor.is_dead:
		return
	
	if !has_damaged:
		has_damaged = true
		actor.damage_players_in_explosion_area()
	
	if !actor.explosion_visual.is_playing():
		actor.die()

func physics_update(_delta: float) -> void:
	actor.velocity = Vector3.ZERO
