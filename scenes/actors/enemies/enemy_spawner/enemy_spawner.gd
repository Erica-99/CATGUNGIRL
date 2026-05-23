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
# how much should be sliced for path comparison
const COMPARE_SLICE: int = 2

func _ready() -> void:
	# link up spawn signal
	EventManager.spawn_enemy.connect(_spawn_enemy)

# actually start spawning timer
func _spawn_enemy(custom_delay: float, spawner_path: NodePath):
	if enemies.get_path_to(self) == spawner_path.slice(COMPARE_SLICE):
		if custom_delay == 0:
			custom_delay = base_spawn_delay
		spawn_delay_timer.start(custom_delay)

# create enemy
func _on_spawn_delay_timer_timeout() -> void:
	var convict = CONVICT_PREFAB.instantiate()
	linked_enemy_manager.add_child(convict)
	# owner must be assigned for enemy manager to recognise an enemy as a child
	convict.owner = linked_enemy_manager
	convict.global_position = spawn_point.global_position
	linked_enemy_manager._check_enemies_remaining(convict)
