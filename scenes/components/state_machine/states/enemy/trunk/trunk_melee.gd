extends State
class_name TrunkMelee

enum MeleePhase {
	APPROACH,
	WINDUP,
	LUNGE,
	RECOVERY
}

# Information gained from state machine
var actor: CharacterBody3D
var anim: AnimatedSprite3D
var target: CharacterBody3D
var xpos_distance_to_melee: float
var melee_stop_speed: float
var player_offset_position: Vector3
var melee_hitbox: Area3D
var melee_windup_time: float
var melee_lunge_distance: float
var melee_lunge_duration: float
var melee_recovery_time: float
var direction: float = 1.0
var phase: MeleePhase
var phase_timer: float = 0.0
var lunge_speed: float = 0.0

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	target = blackboard["target"]
	xpos_distance_to_melee = blackboard["xpos_distance_to_melee"]
	melee_stop_speed = blackboard["melee_stop_speed"]
	melee_hitbox = blackboard["melee_hitbox"]
	melee_windup_time = blackboard["melee_windup_time"]
	melee_lunge_distance = blackboard["melee_lunge_distance"]
	melee_lunge_duration = blackboard["melee_lunge_duration"]
	melee_recovery_time = blackboard["melee_recovery_time"]

func enter() -> void:
	print("Melee")
	_disable_melee_hitbox()
	direction = sign(target.global_position.x - actor.global_position.x)
	if direction == 0.0:
		direction = actor.facing

	actor.facing = direction
	actor.velocity.x = 0.0
	player_offset_position = target.global_position
	player_offset_position.x -= (xpos_distance_to_melee * direction)
	phase = MeleePhase.APPROACH
	phase_timer = 0.0

func exit() -> void:
	_disable_melee_hitbox()
	actor.velocity.x = 0.0

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	match phase:
		MeleePhase.APPROACH:
			_update_approach(delta)
		MeleePhase.WINDUP:
			_update_windup(delta)
		MeleePhase.LUNGE:
			_update_lunge(delta)
		MeleePhase.RECOVERY:
			_update_recovery(delta)

func _update_approach(_delta: float) -> void:
	var move_direction: float = sign(player_offset_position.x - actor.global_position.x)
	actor.velocity.x = move_direction * melee_stop_speed
	
	if abs(player_offset_position.x - actor.global_position.x) < 3:
		actor.velocity.x = 0.0
		_start_windup()

func _start_windup() -> void:
	print("Melee windup")
	phase = MeleePhase.WINDUP
	phase_timer = melee_windup_time
	actor.velocity.x = 0.0

func _update_windup(delta: float) -> void:
	actor.velocity.x = 0.0
	phase_timer -= delta
	
	if phase_timer <= 0.0:
		_start_lunge()

func _start_lunge() -> void:
	print("Melee lunge")
	phase = MeleePhase.LUNGE
	phase_timer = melee_lunge_duration
	var duration: float = max(melee_lunge_duration, 0.01)
	lunge_speed = melee_lunge_distance / duration
	
	_enable_melee_hitbox()
	
func _update_lunge(delta: float) -> void:
	actor.velocity.x = direction * lunge_speed
	phase_timer -= delta
	
	if phase_timer <= 0.0:
		_start_recovery()	

func _start_recovery() -> void:
	print("Melee recovery")
	_disable_melee_hitbox()
	actor.velocity.x = 0.0
	phase = MeleePhase.RECOVERY
	phase_timer = melee_recovery_time

func _update_recovery(delta: float) -> void:
	actor.velocity.x = 0.0
	phase_timer -= delta
	
	if phase_timer <= 0.0:
		transitioned.emit(self, "trunkchase")

func _enable_melee_hitbox() -> void:
	if melee_hitbox == null:
		return
	
	var shape = melee_hitbox.find_child("*")
	if shape != null:
		shape.set_deferred("disabled", false)

func _disable_melee_hitbox() -> void:
	if melee_hitbox == null:
		return
	
	var shape = melee_hitbox.find_child("*")
	if shape != null:
		shape.set_deferred("disabled", true)

func _on_melee_range_body_exited(_body: Node3D) -> void:
	pass
