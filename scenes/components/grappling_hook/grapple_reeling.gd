extends State
class_name GrappleReeling

var reeling := false

func enter() -> void:
	var delay = blackboard["reel_delay"]
	reeling = false
	_enable_reeling_after_delay(delay)
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
	

func _enable_reeling_after_delay(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	reeling = true
	
	
