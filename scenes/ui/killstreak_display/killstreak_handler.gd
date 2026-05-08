extends Control

@onready var killstreak_progression: TextureProgressBar = $KillstreakProgression
@onready var killstreak_display: RichTextLabel = $KillstreakDisplay

var killstreak: int = 0
var killstreak_timeout: Timer

const BASE_TIMEOUT: float = 2.0
const MAX_KILLSTREAK: int = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.player_hit_by_enemy.connect(_ended_killstreak)
	EventManager.enemy_killed.connect(_increment_killstreak)
	killstreak_timeout = Timer.new()
	killstreak_timeout.one_shot = true
	add_child(killstreak_timeout)
	killstreak_timeout.timeout.connect(_ended_killstreak)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_kill"):
		EventManager.enemy_killed.emit()
	if Input.is_action_just_pressed("debug_damage"):
		EventManager.player_hit_by_enemy.emit()
	
	killstreak_progression.value = killstreak_timeout.time_left

func _ended_killstreak():
	killstreak = 0
	killstreak_display.text = "x " + str(killstreak)
	killstreak_timeout.stop()
	killstreak_progression.value = 0
	print("killstreak ended")

func _increment_killstreak():
	if not killstreak_timeout.is_stopped():
		killstreak += 1
		var bonus_time = (BASE_TIMEOUT - killstreak/MAX_KILLSTREAK)/2
		killstreak_timeout.start(killstreak_timeout.time_left + bonus_time)
	else:
		killstreak_timeout.start(BASE_TIMEOUT)
		killstreak += 1
	
	var shake_rate = killstreak / 2
	var shake_level = killstreak / 4
	if shake_level > 5: shake_level = 5
	killstreak_display.text = "[shake rate=" + str(shake_rate) + " level=" + str(shake_level) + "connected=1]x " + str(killstreak) + "[/shake]"
	
	EventManager.current_killstreak.emit(killstreak)
	print("TIME REMAINING: " + str(killstreak_timeout.time_left))

func _update_internal_insanity():
	pass
