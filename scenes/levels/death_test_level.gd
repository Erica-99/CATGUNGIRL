extends Node3D

@export var player: Node3D
@export var respawn: Node3D

#var scenePath = get_tree().edited_scene_root.filename
#signal currentScene(scene: StringName)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#currentScene.emit(scenePath)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _reset_player():
	pass
