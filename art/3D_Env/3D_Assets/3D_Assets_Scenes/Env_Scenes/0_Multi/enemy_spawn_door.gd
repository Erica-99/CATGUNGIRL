extends StaticBody3D

@export var enemy_manager: EnemyManager

@onready var spawner = $EnemySpawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawner.linked_enemy_manager = enemy_manager
	print("success")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
