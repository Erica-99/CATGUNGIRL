# Death State: when enemy dies, play death animation, fade out sprite, and queue_free
extends State

var actor: CharacterBody3D
var anim: AnimatedSprite3D

var fade_time: float = 0.0
# temp timer, would wanna line it up more with death anim
var basic_timer: float = 0.0

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]

func enter() -> void:
	#anim.play("Death")
	pass

func update(_delta: float) -> void:
	fade_time += _delta
	anim.modulate = Color(1,1,1,lerp(1, 0, fade_time))
	basic_timer += _delta
	if basic_timer > 1:
		actor.queue_free()
