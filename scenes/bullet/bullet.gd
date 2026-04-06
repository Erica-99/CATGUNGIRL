extends CharacterBody3D

## bullet spawned by GunComponent, travels in a direction until it hits something or reaches max range

@export var speed: float = 25.0			# how fast bullet travels (units/second)
@export var max_range: float = 40.0		# how far bullet travels before self destruct (world units)

@onready var hitbox_component = $HitboxComponent
@onready var mesh_instance = $MeshInstance3D

var _direction: Vector3 = Vector3.RIGHT	# default points right
var _distance_traveled: float = 0.0		# tracks total distance for destruction at max range


## called immediately after spawning by GunComponent
func initialize(direction: Vector3, damage_instance: DamageHealInstance, team_comp: Node, bullet_size: float = 1.0) -> void:
	_direction = direction.normalized() # normalise vector for consistent bullet speed

	if hitbox_component != null:
		# pass damage data to hitbox
		hitbox_component.damage_or_heal_instance = damage_instance
		# pass player TeamComponent so hitbox knows who fired bullet
		hitbox_component.team_component = team_comp
		# connects hitbox (hurtbox_hit) signal to _on_hit func
		# called when hitbox overlaps with hurtbox
		hitbox_component.hurtbox_hit.connect(_on_hit)

	# scales the bullet mesh and collision to match size
	scale = Vector3(bullet_size, bullet_size, bullet_size)


func _physics_process(delta: float) -> void:
	# speed calc for all firing directions
	velocity = _direction * speed
	# moves bullet by (velocity * delta) 
	var collision = move_and_collide(velocity * delta)
	# tracks total distance (adds per frame)
	_distance_traveled += speed * delta

	if collision != null or _distance_traveled >= max_range:
		queue_free()	# destroys bullet if hitting geometry OR reaches max range

# replace later when connecting health/insanity
func _on_hit(_hurtbox: Area3D) -> void:
	queue_free()
