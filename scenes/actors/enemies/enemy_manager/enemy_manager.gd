extends Node

class_name EnemyManager

# export vars
@export var room_ID: Enums.Room

# runtime vars
var is_cleared: bool = false

func _ready() -> void:
	# link up signals
	EventManager.enemy_killed.connect(_check_enemies_remaining)

# check if enemies still alive - if yes close, if no opend
func _check_enemies_remaining(enemy):
	if self.is_ancestor_of(enemy):
		var children = find_children("*", "CharacterBody3D", true)
		var room_cleared = true
		
		for child in children:
			if !child.is_dead:
				room_cleared = false
				
		# calls set up like this to ensure signals only emitted when status of room has changed
		if room_cleared:
			is_cleared = true
			print("Room is cleared")
			EventManager.room_cleared.emit(room_ID, is_cleared)
		
		if !room_cleared && is_cleared:
			is_cleared = false
			EventManager.room_cleared.emit(room_ID, is_cleared)
		
