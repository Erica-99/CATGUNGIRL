# Patrol State: Convict walks back and forth
#    TODO: add idle dialogue

# Patrol moves to Chase

extends State

var actor: CharacterBody3D
var anim: AnimatedSprite3D
var patrol_speed: float

var direction: int = 1
var patrol_timer: float = 4 # time in seconds that enemy walks for
var patrol_track: float = 0 # timer tracker

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	patrol_speed = blackboard["patrol_speed"]

func update(_delta: float) -> void:
	patrol_track += _delta
	if patrol_track >= patrol_timer:
		actor.velocity = Vector3.ZERO
		direction *= -1
		patrol_track = 0

func physics_update(_delta: float) -> void:
	anim.play("Walk")
	actor.scale = Vector3(direction, actor.scale.y, actor.scale.z)
	actor.velocity.x += direction * patrol_speed * _delta
	actor.velocity.x = clamp(actor.velocity.x, -patrol_speed, patrol_speed)
	actor.move_and_slide()

func _on_detection_area_3d_body_entered(body):
	if body.is_in_group("player"):
		transitioned.emit(self, "convictchase")

# If damaged in patrol state, go to chase
func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	transitioned.emit(self, "convictchase")
