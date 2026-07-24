# Stun State: Convict freezes for a second after being hit
#    TODO: add stun dialogue???

# Stun moves Chase

extends State

var actor: CharacterBody3D
var anim: AnimationPlayer
var slow_down_speed: float
var total_stun_time: float
var stun_timer: float = 0.0

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	slow_down_speed = blackboard["slow_down_speed"]

func enter() -> void:
	print("Stunned")

func update(_delta: float) -> void:
	stun_timer += _delta
	print("Current Timer Value: %f" %stun_timer)
	if stun_timer >= total_stun_time:
		print("Final Timer Value: %f" %stun_timer)
		#stun_timer = 0.0
		#transitioned.emit(self, "convictidle")
		transitioned.emit(self, "convictchase")

func physics_update(_delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * _delta)
	anim.play("Idle")
	actor.move_and_slide()

#func _on_detection_area_3d_body_entered(body):
	#if body.is_in_group("player"):
		#transitioned.emit(self, "convictchase")

# If damaged in idle state, go to chase
#func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	#transitioned.emit(self, "convictchase")

##### NOTE: Need to finish editing this to be for Stun state
