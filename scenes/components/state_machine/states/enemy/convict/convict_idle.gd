# Idle State: Convict stands still, ready to detect
#    TODO: add idle dialogue

# Idle moves Chase

extends State

var actor: CharacterBody3D
var anim: AnimatedSprite3D
var slow_down_speed: float

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	slow_down_speed = blackboard["slow_down_speed"]

func physics_update(_delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * _delta)
	anim.play("Idle")
	actor.move_and_slide()

func _on_detection_area_3d_body_entered(body):
	if body.is_in_group("player"):
		transitioned.emit(self, "convictchase")

# If damaged in idle state, go to chase
func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	transitioned.emit(self, "convictchase")
