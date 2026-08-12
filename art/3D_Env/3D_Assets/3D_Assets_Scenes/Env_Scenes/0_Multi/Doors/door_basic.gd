extends StaticBody3D

@export var openable = true
@export var animation_player: AnimationPlayer
@export var enemy_manager: Node

var opened = false
var bodies_inside: Array[Node3D] = []

func _ready() -> void:
	EventManager.set_door_openable_state.connect(_set_openable_state)
	
	if enemy_manager != null:
		enemy_manager.stage_cleared.connect(_on_enemy_manager_stage_cleared)

func open(body: Node3D):
	if not body is CharacterBody3D:
		return
		
	if !bodies_inside.has(body):
		bodies_inside.append(body)
	
	if openable and not opened:
		if enemy_manager != null:
			if enemy_manager.is_cleared or enemy_manager.get_child_count() == 0:
				opened = true
				animation_player.play("DoorBasic_Opening")
		else:
			opened = true
			animation_player.play("DoorBasic_Opening")

func close(body: Node3D):
	if not body is CharacterBody3D:
		return
		
	if bodies_inside.has(body):
		bodies_inside.erase(body)
	
	if bodies_inside.is_empty():
		if opened or not openable:
			opened = false
			animation_player.play("DoorBasic_IdleClosed")

func _on_door_basic_animation_player_animation_finished(_anim_name: StringName) -> void:
	if opened:
		animation_player.play("DoorBasic_IdleOpen")
	else:
		animation_player.play("DoorBasic_IdleClosed")

func _set_openable_state(object_check: Node3D, new_state: bool):
	if object_check == self:
		openable = new_state

func _on_enemy_manager_stage_cleared() -> void:
	if openable and !opened and !bodies_inside.is_empty():
		open(bodies_inside[0])
