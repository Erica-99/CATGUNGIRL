# Death State: when enemy dies, play death animation, fade out sprite, and queue_free
extends State
class_name EnemyDeath

@export var max_death_animation_time: float = 5

var death_gpu_emitter = preload("res://scenes/VFX/blood_spurt_medium_vfx.tscn")

@onready var VFX_spawn_node = $"../../../../../VFX"

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
	blood_VFX.position = VFX_spawn.global_position
	VFX_spawn_node.add_child(blood_VFX)

	AudioManager.play_sfx("gore_1")
	randomize()
	var deathid = 'Death' + str(randi_range(1,3))
	print(deathid)
	anim.play(deathid)
	EventManager.enemy_killed.emit(self)
	
	for child in actor.find_children("*", "Area3D", true):
		child.collision_layer = 0
		child.collision_mask = 0
		child.hide()
	

func update(_delta: float) -> void:
	fade_time += _delta
	#anim.modulate = Color(1,1,1,lerp(1, 0, fade_time))
	basic_timer += _delta
	if basic_timer > max_death_animation_time:
		actor.queue_free()
