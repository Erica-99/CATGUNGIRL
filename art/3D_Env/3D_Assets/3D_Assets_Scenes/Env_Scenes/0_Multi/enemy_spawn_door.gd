extends Node3D

@export var enemy_manager: EnemyManager

@onready var spawner = $EnemySpawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Assign the EnemyManager for the spawner
	spawner.linked_enemy_manager = enemy_manager
	pass # Replace with function body.
