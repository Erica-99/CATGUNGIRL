class_name AltStateMachine

#current state
var state: State

#sets a new state if target state is different from current state, or if force_reset  is true
func set_state(new_state: State, force_reset: bool = false) -> void:
	if state != new_state or force_reset:
		if state:
			state.exit()
		state = new_state
		state.initialise(self)
		state.enter()
