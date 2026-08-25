extends Node3D

class_name EnemySpawner

# exported vars
@export var base_spawn_delay: float = 2.0
@export var linked_enemy_manager: EnemyManager

# reference vars
@onready var spawn_delay_timer: Timer = $SpawnDelayTimer
@onready var spawn_point: Marker3D = $SpawnPoint
@onready var enemies: Node3D = $"../.."

# TODO: replace with other enemy types when others are in game
const CONVICT_PREFAB = preload("res://scenes/actors/enemies/convict/convict_enemy.tscn")
const SCRUB_PREFAB = preload("res://scenes/actors/enemies/scrub/scrub.tscn")
# how much should be sliced for path comparison
const COMPARE_SLICE: int = 2

#@export var possible_spawns: Array = [CONVICT_PREFAB, SCRUB_PREFAB]
@export var possible_spawns: Array[Enums.EnemyType] = [Enums.EnemyType.CONVICT, Enums.EnemyType.SCRUB]
var possible_prefabs: Array = []

#Wave Settings
@export_category("Wave Settings")
@export var wave_spawner = false
@export var wave_enemies: Array[Enums.EnemyType] = [Enums.EnemyType.CONVICT, Enums.EnemyType.SCRUB]
 
var check_timer: bool = false

func _ready() -> void:
	# link up spawn signal
	EventManager.spawn_enemy.connect(_spawn_enemy)
	
	for enemy in possible_spawns:
		var prefab
		if enemy == Enums.EnemyType.CONVICT:
			prefab = CONVICT_PREFAB
		else:
			prefab = SCRUB_PREFAB
		possible_prefabs.append(prefab)

# actually start spawning timer
func _spawn_enemy(custom_delay: float, spawner_path: NodePath):
	#print("1st If triggered")
	if wave_spawner:
		for wave_enemy in wave_enemies:
			var enemy
			if wave_enemy == Enums.EnemyType.CONVICT:
				enemy = CONVICT_PREFAB
			else:
				enemy = SCRUB_PREFAB
			enemy = enemy.instantiate()
			_add_to_manager(enemy)
	else:
		if enemies.get_path_to(self) == spawner_path.slice(COMPARE_SLICE):
			print("2nd If triggered")
			if custom_delay == 0:
				custom_delay = base_spawn_delay
			spawn_delay_timer.start(custom_delay)
			#check_timer = true

func _process(delta):
	pass
	#if check_timer:
		#print("Current Spawn Timer:", delta)

# create enemy
func _on_spawn_delay_timer_timeout() -> void:
	print("timer ran out, should spawn now")
	var random_prefab = possible_prefabs[randi_range(0, possible_prefabs.size() - 1)]
	var enemy = random_prefab.instantiate()
	_add_to_manager(enemy)
	
func _add_to_manager(enemy): # owner must be assigned for enemy manager to recognise an enemy as a child
	linked_enemy_manager.add_child(enemy)
	enemy.owner = linked_enemy_manager
	enemy.global_position = spawn_point.global_position
	linked_enemy_manager._check_enemies_remaining(enemy)
