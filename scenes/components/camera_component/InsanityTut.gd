extends CanvasLayer

@onready var TutUI = $"."

@onready var tutorialbox_anim = $AnimationPlayer

var TutActive = false

func _ready() -> void:
	tutorialbox_anim.play("idle gone")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		if TutActive == true:
			tutorialbox_anim.play("Fade out")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Fade in":
		TutActive = true
	if anim_name == 'Fade out':
		TutUI.queue_free()
	
	pass # Replace with function body.
