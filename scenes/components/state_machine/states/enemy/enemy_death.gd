extends State
class_name EnemyDeath

var animator: AnimatedSprite3D

var death_timer: float

func enter() -> void:
	# Play Death Animation
	# Play animation (changes color for test)
	animator = blackboard["anim"]
	animator.modulate = Color(0.0, 0.0, 0.0, 1.0)
	
	# Play death sound
	AudioManager.play_sfx("gore_1")
	
	EventManager.enemy_killed.emit()
	var timer := Timer.new()
	timer.wait_time = 1.5
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timeout)
	timer.start()

func _on_timeout():
	blackboard["actor"].queue_free()
