extends Node

class_name EnemyManager

@export var room_ID: Enums.Room

var is_cleared: bool = false

func _ready() -> void:
	EventManager.enemy_killed.connect(_check_enemies_remaining)

func _check_enemies_remaining():
	var children = find_children("*", "CharacterBody3D", true)
	var room_cleared = true
	for child in children:
		if !child.is_dead:
			room_cleared = false
	
	if room_cleared:
		is_cleared = true
		EventManager.room_cleared.emit(room_ID, is_cleared)
	
	if !room_cleared && is_cleared:
		is_cleared = false
		EventManager.room_cleared.emit(room_ID, is_cleared)
		
