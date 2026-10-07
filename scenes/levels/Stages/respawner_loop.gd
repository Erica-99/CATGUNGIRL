extends Node

@export var respawn_event_trigger: Area3D
@export var spawner: EnemySpawner

var enabled = true

func _ready() -> void:
	EventManager.stage_6b_dialogue_completed.connect(_disable_from_event)

func _on_terminal_stage_cleared() -> void:
	if enabled:
		spawner.can_spawn = true
		respawn_event_trigger._emit_signal()

func _disable_from_event() -> void:
	enabled = false
