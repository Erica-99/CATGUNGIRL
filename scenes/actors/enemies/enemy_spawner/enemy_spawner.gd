extends Node3D

class_name EnemySpawner

@export var base_spawn_delay: float = 2.0
@export var linked_enemy_manager: EnemyManager

@onready var spawn_delay_timer: Timer = $SpawnDelayTimer
@onready var spawn_point: Marker3D = $SpawnPoint
@onready var enemies: Node3D = $"../.."

const CONVICT_PREFAB = preload("res://scenes/actors/enemies/convict/convict_enemy.tscn")

func _ready() -> void:
	EventManager.spawn_enemy.connect(_spawn_enemy)

func _spawn_enemy(custom_delay: float, spawner_path: NodePath):
	if enemies.get_path_to(self) == spawner_path.slice(2):
		if custom_delay == 0:
			custom_delay = base_spawn_delay
			
		spawn_delay_timer.start(custom_delay)


func _on_spawn_delay_timer_timeout() -> void:
	var convict = CONVICT_PREFAB.instantiate()
	convict.global_position = global_position
	linked_enemy_manager.add_child(convict)
	convict.owner = linked_enemy_manager
	linked_enemy_manager._check_enemies_remaining()
