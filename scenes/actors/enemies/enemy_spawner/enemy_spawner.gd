extends Node3D

class_name EnemySpawner

# exported vars
@export var base_spawn_delay: float = 2.0
@export var linked_enemy_manager: EnemyManager
#@export var spawn_trigger: Area3D

# reference vars
@onready var spawn_delay_timer: Timer = $SpawnDelayTimer
@onready var spawn_point: Marker3D = $SpawnPoint
@onready var enemies: Node3D = $"../.."

# TODO: replace with other enemy types when others are in game
const CONVICT_PREFAB = preload("res://scenes/actors/enemies/convict/convict_enemy.tscn")
const SCRUB_PREFAB = preload("res://scenes/actors/enemies/scrub/scrub.tscn")
const TRUNK_PREFAB = preload("res://scenes/actors/enemies/trunk/trunk.tscn")
const BRAINSPIDER_PREFAB = preload("res://scenes/actors/enemies/brain_spider/brain_spider.tscn")
# how much should be sliced for path comparison
const COMPARE_SLICE: int = 2

#@export var possible_spawns: Array = [CONVICT_PREFAB, SCRUB_PREFAB]
@export var possible_spawns: Array[Enums.EnemyType] = [Enums.EnemyType.CONVICT, Enums.EnemyType.SCRUB]
var possible_prefabs: Array = []

#Wave Settings
@export_category("Wave Settings")
@export var wave_spawner = false
@export var wave_enemies: Array[Enums.EnemyType] = [Enums.EnemyType.CONVICT, Enums.EnemyType.SCRUB]
@export var has_trigger = false
@export var spawn_trigger: Area3D

var spawn_ids: Array = []
var can_spawn = true


func _ready() -> void:
	# link up spawn signal
	EventManager.spawn_enemy.connect(_spawn_enemy)
	linked_enemy_manager.child_exiting_tree.connect(_remove_id_)
	
	for enemy in possible_spawns:
		var prefab
		match enemy:
			Enums.EnemyType.CONVICT:
				prefab = CONVICT_PREFAB
			Enums.EnemyType.SCRUB:
				prefab = SCRUB_PREFAB
			Enums.EnemyType.TRUNK:
				prefab = TRUNK_PREFAB
			Enums.EnemyType.BRAINSPIDER:
				prefab = BRAINSPIDER_PREFAB
		possible_prefabs.append(prefab)

# actually start spawning timer
func _spawn_enemy(custom_delay: float, spawner_path: NodePath):
	if wave_spawner:
		if can_spawn:
			for wave_enemy in wave_enemies:
				var enemy
				match wave_enemy:
					Enums.EnemyType.CONVICT:
							enemy = CONVICT_PREFAB
					Enums.EnemyType.SCRUB:
						enemy = SCRUB_PREFAB
					Enums.EnemyType.TRUNK:
						enemy = TRUNK_PREFAB
					Enums.EnemyType.BRAINSPIDER:
						enemy = BRAINSPIDER_PREFAB
				enemy = enemy.instantiate()
				spawn_ids.append(enemy.get_instance_id())
				_add_to_manager(enemy)
			print(spawn_ids)
			if has_trigger:
				spawn_trigger.active = false
			else:
				can_spawn = false
			print("Spawning has been set to: ", can_spawn)
	else:
		if enemies.get_path_to(self) == spawner_path.slice(COMPARE_SLICE):
			if custom_delay == 0:
				custom_delay = base_spawn_delay
			spawn_delay_timer.start(custom_delay)

# create enemy
func _on_spawn_delay_timer_timeout() -> void:
	var random_prefab = possible_prefabs[randi_range(0, possible_prefabs.size() - 1)]
	var enemy = random_prefab.instantiate()
	_add_to_manager(enemy)
	
func _add_to_manager(enemy): # owner must be assigned for enemy manager to recognise an enemy as a child
	linked_enemy_manager.add_child(enemy)
	enemy.owner = linked_enemy_manager
	enemy.global_position = spawn_point.global_position
	linked_enemy_manager._check_enemies_remaining(enemy)

func _remove_id_(enemy: CharacterBody3D):
	var id = enemy.get_instance_id()
	if id in spawn_ids:
		spawn_ids.erase(id)
	if spawn_ids.is_empty():
		if has_trigger:
			spawn_trigger.active = true
		else:
			can_spawn = true
