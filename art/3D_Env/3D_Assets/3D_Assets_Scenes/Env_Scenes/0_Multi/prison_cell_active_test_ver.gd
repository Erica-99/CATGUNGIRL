extends StaticBody3D

var spawner_path: NodePath

@export var cell_anim_player: AnimationPlayer
@export var enemy_spawner: EnemySpawner

func _ready() -> void:
	EventManager.connect("start_animation", _on_start_animation)
	cell_anim_player.animation_finished.connect(_on_animation_player_animation_finished)
	
	var spawner_path = enemy_spawner.get_path()
	
	cell_anim_player.play("Cell_IdleClosed")

func _on_start_animation() -> void:
	#print("Animation starting now")
	cell_anim_player.play("Cell_Opening")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Cell_Opening":
		EventManager.emit_signal("spawn_enemy", 2.0, spawner_path)
		print("Enemy should spawn now")
