extends Node3D
@onready var parent = $"."
@onready var fallinganim = $PrisonCell/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	parent.position = Vector3(randf_range(43.194,146.126), randf_range(323.315,344.992), randf_range(-34.543,-50))
	fallinganim.play("Falling_0"+str(randi_range(1,5)))
	pass # Replace with function body.
