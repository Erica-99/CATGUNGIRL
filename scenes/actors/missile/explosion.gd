extends Node3D


func _ready() -> void:
	$Timer.wait_time = 0.15
	$Timer.start()


func _on_timer_timeout() -> void:
	print("Explosion freed")
	queue_free()
