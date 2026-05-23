extends RigidBody2D

const MAX_OPACITY: float = 1.0
const LIFETIME: float = 6

var velocity: Vector2 = Vector2(200, 800)

var rate_of_transparency = MAX_OPACITY / (LIFETIME * 60)

func _physics_process(delta: float) -> void:
	modulate.a -= rate_of_transparency
	if modulate.a < 0:
		self.queue_free()

	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
