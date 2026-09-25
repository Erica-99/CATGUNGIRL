extends CharacterBody3D

@export var state_machine: StateMachine

var blackboard: Dictionary
var anims: AnimationPlayer

func _ready() -> void:
	blackboard = {
	"actor": self,
	"player": get_tree().get_first_node_in_group("player"),
	"anims": $AnimationPlayer
	}

	state_machine.init(blackboard)
	anims = blackboard['anims']

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'Activate':
		anims.play('Active')
	pass # Replace with function body.
