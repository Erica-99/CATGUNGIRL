extends State
class_name TrunkIdle

# Information gained from state machine
var actor: CharacterBody3D
var anim: AnimatedSprite3D
var min_idle_time: float
var max_idle_time: float
var idle_timer: Timer


func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	idle_timer = Timer.new()
	idle_timer.one_shot = false
	idle_timer.timeout.connect(_switch_to_patrol)
	add_child(idle_timer)
	min_idle_time = blackboard["min_idle_time"]
	max_idle_time = blackboard["max_idle_time"]

func enter() -> void:
	print("Idle")
	idle_timer.wait_time = randf_range(min_idle_time, max_idle_time)
	idle_timer.start()
	
	actor._stop_step_handler()

func exit() -> void:
	idle_timer.stop()
	
	actor._reset_step_handler()

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, delta)
	#anim.play("idle")
	
	actor.move_and_slide()

func _on_detection_range_body_entered(body: Node3D) -> void:
	actor.detected_player = true
	transitioned.emit(self, "trunkchase")

func _switch_to_patrol():
	transitioned.emit(self, "trunkpatrol")
