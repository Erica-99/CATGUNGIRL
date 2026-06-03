extends StaticBody3D

@export var openable = true
@export var animation_player: AnimationPlayer

var opened = false

func open(body: Node3D):
	if openable and not opened:
		opened = true
		animation_player.play("DoorBasic_Opening")

func close(body: Node3D):
	if opened or not openable:
		opened = false
		animation_player.play("DoorBasic_IdleClosed")

func _on_door_basic_animation_player_animation_finished(anim_name: StringName) -> void:
	if opened:
		animation_player.play("DoorBasic_IdleOpen")
	else:
		animation_player.play("DoorBasic_IdleClosed")
