# Death State: when enemy dies, play death animation, fade out sprite, and queue_free
extends State
class_name EnemyDeath

@export var max_death_animation_time: float = 2
@export var leave_trunk_corpse_on_kill: bool
var death_gpu_emitter = preload("res://scenes/VFX/blood_spurt_medium_vfx.tscn")
var explosion_gpu_emitter = preload("res://art/TechArt/1_Shaders/explosion_test.tscn")
var trunk_corpse = preload('res://art/TechArt/4_Misc/trunk_corpse_prop.tscn')
var actor: CharacterBody3D
var anim: AnimationPlayer

var fade_time: float = 0.0
# temp timer, would wanna line it up more with death anim
var basic_timer: float = 0.0

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]

func enter() -> void:
	#anim.play("Death")
	# Play death sound
	var blood_VFX = death_gpu_emitter.instantiate()
	var VFX_spawn = $"../../VFX_target"
	var VFX_spawn_node = get_tree().current_scene.get_node_or_null("VFX")
	if VFX_spawn_node == null:
		push_warning("No VFX node found in current scene")
		return

	blood_VFX.global_position = VFX_spawn.global_position
	VFX_spawn_node.add_child(blood_VFX)
	
	AudioManager.play_sfx("enemy_death")
	randomize()
	var deathid = 'Death' + str(randi_range(1,3))
	print(deathid)
	anim.play(deathid)

	EventManager.enemy_killed.emit(self)
	
	for child in actor.find_children("*", "Area3D", true):
		if child.name != "DeathDetector":
			child.collision_layer = 0
			child.collision_mask = 0
			child.hide()
	
func spawn_explosion():
		var corpse_prop = trunk_corpse.instantiate()
		var explosion_VFX = explosion_gpu_emitter.instantiate()
		var VFX_spawn = $"../../Explosion_target"
		var VFX_spawn_node = get_tree().current_scene.get_node_or_null("VFX")
		if VFX_spawn_node == null:
			push_warning("No VFX node found in current scene")
			return
		explosion_VFX.global_position = VFX_spawn.global_position
		corpse_prop.global_position = actor.global_position
		VFX_spawn_node.add_child(explosion_VFX)
		VFX_spawn_node.add_child(corpse_prop)
		
func update(_delta: float) -> void:
	fade_time += _delta
	#anim.modulate = Color(1,1,1,lerp(1, 0, fade_time))
	basic_timer += _delta
	if basic_timer > max_death_animation_time:
		if leave_trunk_corpse_on_kill == true:
			spawn_explosion()
		actor.queue_free()
