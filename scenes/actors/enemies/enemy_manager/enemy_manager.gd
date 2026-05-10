extends Node

@export var room_ID: Enums.Room

func _ready() -> void:
	EventManager.enemy_killed.connect(_check_enemies_remaining)

func _check_enemies_remaining():
	var children = find_children("*", "CharacterBody3D", true)
	var room_cleared = true
	for child in children:
		if child.state is not EnemyDeath:
			room_cleared = false
	
	if room_cleared:
		EventManager.room_cleared.emit(room_ID)
