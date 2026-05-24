extends State
class_name EnemySearch

var actor: CharacterBody3D

@export var animator: AnimationPlayer

@export var look_time: float
@export var look_count: int
@export var animation = ''

var look_timer: float
var look_counter: int

func enter() -> void:
	animator.play(animation)
	
	look_timer = 0
	look_counter = 0
	actor = blackboard["actor"]
	actor.velocity.x = 0
	actor.scale.x*= -1
	actor.move_and_slide()
	

func update(_delta: float) -> void:
	look_timer += _delta
	
	if look_timer >= look_time:
		actor.scale.x *= -1
		look_timer = 0
		look_counter += 1
		
	
	if look_counter >= look_count:
		complete("Search Finished")

	pass
