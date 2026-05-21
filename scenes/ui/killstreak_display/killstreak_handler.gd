extends Control

@onready var killstreak_progression: TextureProgressBar = $KillstreakProgression
@onready var killstreak_display: RichTextLabel = $KillstreakDisplay

@export var mini_gigis_active: bool = false

var killstreak: int = 0
var killstreak_timeout: Timer

const BASE_TIMEOUT: float = 2.0
const MAX_KILLSTREAK: int = 20
const SHAKE_RATE_MULTIPLIER: float = 0.5
const SHAKE_LEVEL_MULTIPLIER: float = 0.25

var mini_gigi_prefab = preload("res://scenes/ui/killstreak_display/mini_gi_gi_emotes.tscn")

func _ready() -> void:
	randomize()
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
	
func _increment_killstreak():
	if not killstreak_timeout.is_stopped():
		killstreak += 1
		var bonus_time = (BASE_TIMEOUT - killstreak/MAX_KILLSTREAK) / 2
		killstreak_timeout.start(killstreak_timeout.time_left + bonus_time)
	else:
		killstreak_timeout.start(BASE_TIMEOUT)
		killstreak += 1
	
	var shake_rate = killstreak * SHAKE_RATE_MULTIPLIER
	var shake_level = killstreak * SHAKE_LEVEL_MULTIPLIER
	if shake_level > 5: shake_level = 5
	killstreak_display.text = "[shake rate=" + str(shake_rate) + " level=" + str(shake_level) + "connected=1]x " + str(killstreak) + "[/shake]"
	EventManager.current_killstreak.emit(killstreak)
	
	if mini_gigis_active:
		if randi_range(0, 10) >= 9:
			_add_mini_gigi()
	
func _add_mini_gigi():
	var mini_gigi = mini_gigi_prefab.instantiate()
	var x_direction = randi_range(-400, 400)
	mini_gigi.velocity.x = x_direction
	add_child(mini_gigi)
