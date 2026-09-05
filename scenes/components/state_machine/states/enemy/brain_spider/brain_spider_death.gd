extends State

var actor: BrainSpider
var death_timer: float = 0.0
var fall_timer: float = 0.0
var has_exploded: bool = false

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]

func enter() -> void:
	death_timer = 0.0
	fall_timer = 0.0
	has_exploded = false
	actor.is_dying = true
	actor.velocity = Vector3.ZERO
	actor.laser.visible = false
	actor.is_in_turret_form = false
	actor.show_spider_visual()
	
	if actor.spider_mode == BrainSpider.SpiderMode.FLOOR:
		play_death_explosion()

func update(delta: float) -> void:
	if actor.is_dead:
		return
	
	if !has_exploded:
		fall_timer += delta
		
		if fall_timer >= actor.fall_death_max_time:
			play_death_explosion()
		
		return
	
	death_timer += delta
	
	if death_timer >= actor.death_duration:
		actor.die()

func physics_update(delta: float) -> void:
	if actor.is_dead:
		return
	
	if has_exploded:
		actor.velocity = Vector3.ZERO
		return
	
	if !actor.is_on_floor():
		actor.velocity.y -= actor.gravity * delta
	else:
		actor.velocity.y = 0.0
	
	actor.velocity.x = move_toward(actor.velocity.x, 0.0, actor.acceleration * delta)
	actor.velocity.z = 0.0
	actor.move_and_slide()
	
	if actor.spider_mode == BrainSpider.SpiderMode.WALL_CEILING and actor.is_on_floor():
		play_death_explosion()

func play_death_explosion() -> void:
	if has_exploded:
		return
	
	has_exploded = true
	death_timer = 0.0
	actor.velocity = Vector3.ZERO
	actor.show_explosion_effect()
