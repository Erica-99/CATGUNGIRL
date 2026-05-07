extends CharacterBody3D
class_name ConvictEnemy

# Node References
@export var animator: AnimatedSprite3D
@export var health_comp: Node
@export var state_machine: StateMachine
@export var attack_hitbox: Area3D

@export_category("Stat Variables")
@export var patrol_speed: float
@export var chase_speed: float
@export var slow_down_speed: float

var blackboard : Dictionary 

func _ready() -> void:
	# Populates blackboard and distributes it to all states
	blackboard = {
		"actor": self,
		"anim": animator,
		"patrol_speed": patrol_speed,
		"chase_speed": chase_speed,
		"slow_down_speed": slow_down_speed,
		"attack_hitbox": attack_hitbox
	}
	
	state_machine.init(blackboard)

func _on_detection_area_3d_body_entered(body):
	if body.is_in_group("player"):
		if state_machine.current_state != state_machine.states["convictchase"]:
			state_machine.on_child_transition(state_machine.current_state, "convictchase")

func _on_attack_hit_box_3d_body_entered(body):
	if body.is_in_group("player"):
		state_machine.on_child_transition(state_machine.current_state, "convicthitconfirm")
		
func _on_convict_hit_confirm_attack_cd_finished():
	state_machine.on_child_transition(state_machine.current_state, "convictchase")
