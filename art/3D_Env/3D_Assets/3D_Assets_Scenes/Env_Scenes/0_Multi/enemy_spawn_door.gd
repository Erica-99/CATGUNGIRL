extends Node3D

@export var enemy_manager: EnemyManager

@onready var spawner = $EnemySpawner
@onready var animation = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Assign the EnemyManager for the spawner
	spawner.linked_enemy_manager = enemy_manager
	spawner.enemy_spawned.connect(_on_enemy_spawned)

func _on_enemy_spawned():
	animation.play("DoorAnims/Open&Close")
