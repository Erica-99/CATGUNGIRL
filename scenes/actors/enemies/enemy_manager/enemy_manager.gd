extends Node

class_name EnemyManager

# export vars
@export var room_ID: Enums.Room
@export var convict_route_points: Node3D

# runtime vars
var is_cleared: bool = false
var paused_enemy_process_modes: Dictionary = {}

signal stage_cleared

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
			stage_cleared.emit()
			EventManager.room_cleared.emit(room_ID, is_cleared)
		
		if !room_cleared && is_cleared:
			is_cleared = false
			EventManager.room_cleared.emit(room_ID, is_cleared)

func get_convict_route_points() -> Array:
	var points: Array = []
	
	if convict_route_points == null:
		return points
	
	for child in convict_route_points.get_children():
		if child is Marker3D:
			points.append(child)
	
	return points

func kill_all_enemies() -> void:
	var enemies = find_children("*", "CharacterBody3D", true)
	
	for enemy in enemies:
		if enemy.get("is_dead") == true:
			continue
		
		var health_component: HealthComponent = enemy.get_node_or_null("HealthComponent")
		
		if health_component == null:
			health_component = enemy.get("health_comp")
		
		if health_component == null:
			continue
		
		var debug_damage = DamageHealInstance.new()
		debug_damage.amount = 99999
		debug_damage.is_heal = false
		debug_damage.type = Enums.DamageType.NORMAL
		debug_damage.knockback = 0.0
		debug_damage.stun_time = 0.0
		debug_damage.source = get_path()
		health_component.take_damage_or_heal(debug_damage)

func set_enemies_paused(enabled: bool) -> void:
	var enemies = find_children("*", "CharacterBody3D", true)
	
	for enemy in enemies:
		if enemy.get("is_dead") == true:
			continue
		
		if enabled:
			if !paused_enemy_process_modes.has(enemy):
				paused_enemy_process_modes[enemy] = enemy.process_mode
			
			enemy.velocity = Vector3.ZERO
			enemy.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			if paused_enemy_process_modes.has(enemy):
				enemy.process_mode = paused_enemy_process_modes[enemy]
			else:
				enemy.process_mode = Node.PROCESS_MODE_INHERIT
	
	if !enabled:
		paused_enemy_process_modes.clear()
