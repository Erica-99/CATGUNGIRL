extends StaticBody3D

@export var openable = true
@export var animation_player: AnimationPlayer
@export var enemy_manager: Node

var opened = false

func _ready() -> void:
	EventManager.set_door_openable_state.connect(_set_openable_state)

func open(body: Node3D):
	if openable and not opened:
		if enemy_manager.is_cleared or enemy_manager.get_child_count() == 0:
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

func _set_openable_state(object_check: Node3D, new_state: bool):
	if object_check == self:
		openable = new_state
