extends State

var actor: BrainSpider
var aim_timer: float = 0.0
var lock_timer: float = 0.0
var morph_timer: float = 0.0
var aim_locked: bool = false
var turret_ready: bool = false
var morphing_to_spider: bool = false
var anim: AnimationPlayer
var charge_sound_played: bool = false
var shake_time: float = 0.0
var visual_start_position: Vector3

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]

func enter() -> void:
	aim_timer = 0.0
	lock_timer = 0.0
	morph_timer = 0.0
	aim_locked = false
	turret_ready = actor.is_in_turret_form
	morphing_to_spider = false
	actor.velocity = Vector3.ZERO
	actor.laser.visible = false
	charge_sound_played = false
	shake_time = 0.0
	visual_start_position = actor.shake_visual.position
	
	if actor.is_in_turret_form:
		actor.set_turret_damage_multiplier()
		
	#for when animation is added
	if actor.animator != null and !actor.is_in_turret_form:
		actor.animator.play("Turret")

func exit() -> void:
	actor.shake_visual.position = visual_start_position
	
	if !morphing_to_spider and actor.stinger_caller != null:
		actor.stinger_caller.stop()

func update(delta: float) -> void:
	if actor.is_dying or actor.is_dead:
		return
	
	if actor.target == null or !is_instance_valid(actor.target):

		start_morph_to_spider()
		return
	
	if morphing_to_spider:
		morph_timer += delta
		
		if morph_timer >= actor.morph_spider_time:
			actor.is_in_turret_form = false
			transitioned.emit(self, "brainspidersurfacechase")
		
		return
	
	if !turret_ready:
		morph_timer += delta
		
		if morph_timer >= actor.morph_turret_time:
			turret_ready = true
			actor.is_in_turret_form = true
			actor.set_turret_damage_multiplier()
			morph_timer = 0.0
		
		return
	
	if !actor.has_line_of_sight():
		start_morph_to_spider()
		return
	
	if actor.laser_cooldown_timer > 0.0:
		actor.laser.visible = false
		actor.laser_cooldown_timer -= delta
		return
	
	if !charge_sound_played:
		charge_sound_played = true
	
		if actor.stinger_caller != null and actor.laser_charge_sound != null:
			actor.stinger_caller.stop()
			actor.stinger_caller.stream = actor.laser_charge_sound
			actor.stinger_caller.pitch_scale = actor.laser_charge_pitch
			actor.stinger_caller.play()
	
	actor.laser.visible = true
	shake_time += delta
	var charge_progress: float = minf(aim_timer / maxf(actor.laser_track_time, 0.001), 1.0)
	var shake_strength: float = actor.laser_charge_shake_strength * charge_progress
	var horizontal_shake: float = sin(shake_time * actor.laser_charge_shake_speed) * shake_strength
	actor.shake_visual.position = visual_start_position + Vector3(horizontal_shake, 0.0, 0.0)

	if !aim_locked:
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

func start_morph_to_spider() -> void:
	if morphing_to_spider:
		return
	
	if charge_sound_played and actor.stinger_caller != null:
		actor.stinger_caller.stop()
		
		if actor.laser_power_down_sound != null:
			actor.stinger_caller.stream = actor.laser_power_down_sound
			actor.stinger_caller.pitch_scale = actor.laser_power_down_pitch
			actor.stinger_caller.play()
	
	charge_sound_played = false
	
	actor.shake_visual.position = visual_start_position
	anim.play('Emerge')
	morphing_to_spider = true
	morph_timer = 0.0
	actor.laser.visible = false
	actor.set_spider_damage_multiplier()
	# actor.animator.play("MorphToSpider")
