extends Node3D

@export var hook_anchor: Vector3 = Vector3(0, 0, 0)
@export var gun_anchor: Vector3 = Vector3(0, 0, 0)

var gun_anchor_object: Node3D
var latched_body: Node3D = null
var can_latch: bool = true
var collided: bool = false

@onready var rope: MeshInstance3D = $Rope

func _ready() -> void:
	hook_anchor = Vector3.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if latched_body:
			global_position = latched_body.global_position
	
	rope.set_points(hook_anchor, gun_anchor)

func _physics_process(delta: float) -> void:
	if gun_anchor_object == null:
		queue_free()
	else:		
		hook_anchor = Vector3.ZERO
		gun_anchor = gun_anchor_object.global_position - global_position


func _on_early_collision_body_entered(body: Node3D) -> void:
	collided = true


func _on_early_collision_enemy_body_entered(body: Node3D) -> void:
	if can_latch:
		latched_body = body
		can_latch = false
