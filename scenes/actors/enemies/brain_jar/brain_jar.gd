extends Node

var hurtbox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hurtbox = $HurtboxComponent

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func disable_shields():
	pass

func is_hit():
	if hurtbox.
