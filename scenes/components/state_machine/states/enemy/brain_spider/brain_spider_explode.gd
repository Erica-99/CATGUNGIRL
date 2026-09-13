extends State

var actor: BrainSpider
var explosion_timer: float = 0.0
var has_exploded: bool = false

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]

func enter() -> void:
	explosion_timer = 0.0
	has_exploded = false
	actor.velocity = Vector3.ZERO

func update(delta: float) -> void:
	if actor.is_dead:
		return
	
	if !has_exploded:
		explosion_timer += delta
		
		if explosion_timer >= actor.explosion_delay:
			has_exploded = true
			actor.damage_players_in_explosion_area()
			actor.show_explosion_effect()
		
		return
	
	if !actor.is_explosion_effect_playing():
		actor.die()

func physics_update(_delta: float) -> void:
	actor.velocity = Vector3.ZERO
