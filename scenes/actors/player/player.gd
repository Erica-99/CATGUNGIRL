extends CharacterBody3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

## Extending signals for ui and other components
signal player_health_initialiased(init_current_health: float, init_max_health: float)
signal player_health_changed(old_health, new_health, damage_or_heal_instance)
signal player_insanity_gained(amount, buffer)
signal player_interest_rank_changed(new_rank)

@export var movement_state_machine: StateMachine

var blackboard : Dictionary = {
	"actor": self, 
	"movespeed" : SPEED,
	}

func _ready() -> void:
	movement_state_machine.init(blackboard)


#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()


func _on_health_component_health_initialised(init_current_health, init_max_health):
	player_health_initialiased.emit(init_current_health, init_max_health)

func _on_health_component_health_changed(old_health, new_health, damage_or_heal_instance):
	player_health_changed.emit(old_health, new_health, damage_or_heal_instance)

func _on_insanity_component_insanity_gained(amount, buffer):
	player_insanity_gained.emit(amount, buffer)

## When Insanity reaches max, game over
func _on_insanity_component_insanity_death():
	## TODO: Death stuff
	print("Oof ouch owie I'm dead")

func _on_insanity_component_interest_rank_changed(new_rank):
	player_interest_rank_changed.emit(new_rank)
