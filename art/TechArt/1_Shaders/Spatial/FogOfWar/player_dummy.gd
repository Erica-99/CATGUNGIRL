extends CharacterBody3D


@export var speed: float = 30.0


func _ready() -> void:
	add_to_group(&"player")


func _physics_process(delta: float) -> void:
	var input := Vector3(
			Input.get_axis(&"ui_left", &"ui_right"),
			0.0,
			Input.get_axis(&"ui_up", &"ui_down"))
	if input != Vector3.ZERO:
		global_position += input.normalized() * speed * delta
