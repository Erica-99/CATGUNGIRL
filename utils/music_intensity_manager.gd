extends Node
## remembers the room with an enemymanager the player was last in
## room becomes current room when one of its enemies aggroes or comes on screen 
## stays current until another room's enemies show up

## checks which variation of music should play every .25 seconds
## OFF  - no stage with combat music (menus, Brain Jar), or the player is dead
## HIGH - an enemy in the current room is aggroed
## MID  - enemies near - not aggro
## LOW  - no enemies nearby/onscreen/room or level start

## when the intensity changes, EventManager.music_intensity_changed is emitted
## the audio side only needs to listen to that signal (and handles the fading)

# how often (seconds) the intensity is re-checked
const CHECK_INTERVAL: float = 0.25

# enemy states containing these are calm, anything else counts as aggro
const CALM_STATES: Array[String] = ["idle", "patrol", "death"]

var current_intensity: Enums.MusicIntensity = Enums.MusicIntensity.OFF
# room the player was last engaged in
var current_room: EnemyManager

var _check_timer: float = 0.0
var _current_stage: Node

func _process(delta: float) -> void:
	_check_timer += delta
	if _check_timer < CHECK_INTERVAL:
		return
	
	_check_timer = 0.0
	_update_intensity()

func _update_intensity() -> void:
	var player = get_tree().get_first_node_in_group("player")
	var combat_music_stage = get_tree().get_first_node_in_group("combat_music_stage")
	if combat_music_stage == null or player == null or player.get("is_dead"):
		_set_intensity(Enums.MusicIntensity.OFF)
		return

	# a new stage's combat music always starts at LOW
	if !is_instance_valid(_current_stage) or combat_music_stage != _current_stage:
		_current_stage = combat_music_stage
		current_intensity = Enums.MusicIntensity.LOW

	_update_current_room()
	
	# no room engaged yet in this level (current_room is freed when the level changes)
	if !is_instance_valid(current_room):
		_set_intensity(Enums.MusicIntensity.LOW)
		return
	
	_set_intensity(_get_room_intensity(current_room))

# switches current_room to the room the player is engaging:
# a room with an aggroed enemy first, otherwise a room with an enemy on screen
func _update_current_room() -> void:
	var room_on_screen: EnemyManager = null
	
	for room in get_tree().get_nodes_in_group("enemy_managers"):
		for enemy in _get_living_enemies(room):
			if _is_aggroed(enemy):
				current_room = room
				return
			if room_on_screen == null and _is_on_screen(enemy):
				room_on_screen = room
	
	if room_on_screen != null:
		current_room = room_on_screen

func _get_room_intensity(room: EnemyManager) -> Enums.MusicIntensity:
	var living_enemies := _get_living_enemies(room)
	if living_enemies.is_empty():
		return Enums.MusicIntensity.LOW
	
	for enemy in living_enemies:
		if _is_aggroed(enemy):
			return Enums.MusicIntensity.HIGH
	
	return Enums.MusicIntensity.MID

func _set_intensity(new_intensity: Enums.MusicIntensity) -> void:
	if new_intensity == current_intensity:
		return

	current_intensity = new_intensity
	EventManager.music_intensity_changed.emit(new_intensity)

func _get_living_enemies(room: EnemyManager) -> Array:
	var enemies: Array = []
	
	for enemy in room.find_children("*", "CharacterBody3D", true):
		if !enemy.get("is_dead"):
			enemies.append(enemy)
	
	return enemies

func _is_aggroed(enemy: Node) -> bool:
	var state_machine: StateMachine = enemy.get("state_machine")
	if state_machine == null or state_machine.current_state == null:
		return false
	
	var state_name: String = state_machine.current_state.name.to_lower()
	for calm_state in CALM_STATES:
		if state_name.contains(calm_state):
			return false
	
	return true

func _is_on_screen(enemy: Node3D) -> bool:
	var camera: Camera3D = get_viewport().get_camera_3d()
	return camera != null and camera.is_position_in_frustum(enemy.global_position)
