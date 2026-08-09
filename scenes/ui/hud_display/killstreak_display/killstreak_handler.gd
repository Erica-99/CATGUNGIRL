extends Control

# reference vars
@onready var killstreak_progression: TextureProgressBar = $KillstreakProgression
@onready var killstreak_display: RichTextLabel = $KillstreakDisplay

# export vars
@export var mini_gigis_active: bool = false

# runtime vars
var killstreak: int = 0
var killstreak_timeout: Timer

# consts
const BASE_TIMEOUT: float = 4.0
const MAX_KILLSTREAK: int = 20
const SHAKE_RATE_MULTIPLIER: float = 0.5
const SHAKE_LEVEL_MULTIPLIER: float = 0.25
const MINI_GIGI_PREFAB = preload("res://scenes/ui/hud_display/killstreak_display/mini_gi_gi_emotes.tscn")

func _ready() -> void:
	# make sure randomise is called for random mini gigis
	randomize()
	
	# connect up signals
	EventManager.player_hit_by_enemy.connect(_ended_killstreak)
	EventManager.enemy_killed.connect(_increment_killstreak)
	
	# setup killstreak internal timer
	killstreak_timeout = Timer.new()
	killstreak_timeout.one_shot = true
	add_child(killstreak_timeout)
	killstreak_timeout.timeout.connect(_ended_killstreak)

func _process(delta: float) -> void:
	
	if killstreak == 0:
		modulate = Color(0.0, 0.0, 0.0, 0.118)
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)
	# temp debug calls
	# TODO: REMOVE WHEN NEEDED
	#if Input.is_action_just_pressed("debug_kill"):
		#EventManager.enemy_killed.emit()
	#if Input.is_action_just_pressed("debug_damage"):
		#EventManager.player_hit_by_enemy.emit()
	
	# update progression value	
	killstreak_progression.value = killstreak_timeout.time_left

# reset back to zero once killstreak is over
func _ended_killstreak():
	killstreak = 0
	killstreak_display.text = str(killstreak)
	killstreak_timeout.stop()
	killstreak_progression.value = 0
	
# increase killstreak by one
func _increment_killstreak(enemy):
	# start up killstreak if not started, increment if started etc.
	if not killstreak_timeout.is_stopped():
		killstreak += 1
		var bonus_time = (BASE_TIMEOUT - killstreak/MAX_KILLSTREAK) / 2
		killstreak_timeout.start(killstreak_timeout.time_left + bonus_time)
	else:
		killstreak_timeout.start(BASE_TIMEOUT)
		killstreak += 1
	
	# set shake vars
	var shake_rate = killstreak * SHAKE_RATE_MULTIPLIER
	var shake_level = killstreak * SHAKE_LEVEL_MULTIPLIER
	
	# max shake var
	if shake_level > 5: shake_level = 5
	
	# generate killstreak text
	killstreak_display.text = "[shake rate=" + str(shake_rate) + " level=" + str(shake_level) + "connected=1]x " + str(killstreak) + "[/shake]"
	
	# emit current killstreak for other systems (gui overlay, gigi dialogue etc)
	EventManager.current_killstreak.emit(killstreak)
	
	# mini gigis yayyyy (dude this is so un-needed lmfao but anyways mini gigis yay!!!)
	if mini_gigis_active:
		if randi_range(0, 10) >= 9:
			_add_mini_gigi()
	
	# LET THERE BE MINI GIGIS >:DDD
func _add_mini_gigi():
	var mini_gigi = MINI_GIGI_PREFAB.instantiate()
	var x_direction = randi_range(-400, 400)
	mini_gigi.velocity.x = x_direction
	add_child(mini_gigi)
