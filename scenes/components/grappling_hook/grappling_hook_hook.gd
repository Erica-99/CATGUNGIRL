extends Node3D

@export var hook_anchor: Vector3 = Vector3(0, 0, 0)
@export var gun_anchor: Vector3 = Vector3(0, 0, 0)

var gun_anchor_object: Node3D
var latched_body: Node3D = null
var can_latch: bool = true
var collided: bool = false
var latched_local_position: Vector3 = Vector3.ZERO

@onready var rope: MeshInstance3D = $Rope

func _ready() -> void:
	hook_anchor = Vector3.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(latched_body):
		global_position = latched_body.to_global(latched_local_position)
	
	if gun_anchor_object == null:
		queue_free()
	else:
		gun_anchor = gun_anchor_object.global_position - global_position
	
	rope.set_points(Vector3.ZERO, gun_anchor)

func _physics_process(delta: float) -> void:
	pass

func _on_early_collision_body_entered(body: Node3D) -> void:
	collided = true
	_latch_to_body(body)

func _on_early_collision_enemy_body_entered(body: Node3D) -> void:
	if can_latch:
		latched_body = body
		_latch_to_body(body)

func _latch_to_body(body: Node3D) -> void:
	if !can_latch or body == null:
		return
	
	latched_body = body
	latched_local_position = body.to_local(global_position)
	can_latch = false
