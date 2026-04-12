class_name AltStateMachine

# Current state
var current_state: State

# Sets a new state if target state is different from current state, or if force_reset  is true
func set_state(new_state: State, force_reset: bool = false) -> void:
	if current_state != new_state or force_reset:
		if current_state:
			current_state.exit()
		current_state = new_state
		current_state.reset()
		current_state.enter()
		print("Set state to", current_state)
