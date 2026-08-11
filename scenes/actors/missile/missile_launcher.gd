extends Node

const MISSILE = preload("uid://bt57arw8qv0ya")

@export var spawn_cooldown: float = 4.0
@export var spawn_count: int = 1

var active: bool = false
var spawn_timer: float

func _process(delta: float) -> void:
	if active:
		spawn_timer += delta
		if spawn_timer > spawn_cooldown:
			spawn_timer = 0
			for i in range(spawn_count):
				launch_missile()

# Spawns new missile
func launch_missile() -> void:
	var new_missile = MISSILE.instantiate()
	
	get_tree().root.add_child(new_missile)
	print("Missile Launched")

# Testing Scene Function Only
func _on_button_pressed() -> void:
	if active:
		turn_off()
	else:
		turn_on()

func turn_on() -> void:
	active = true
	spawn_timer = 0

func turn_off() -> void:
	active = false
