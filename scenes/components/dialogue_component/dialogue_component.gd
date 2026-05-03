extends Node

@export var attached_to_team: Enums.Team = Enums.Team.WORLD
@export var can_speak: bool = true
@export var base_transparency_speed: float = 4.0

# set variables to change on initialisation
	# entity can be: player, gun, enemy (including enemy types ie: convict, trunk, scrub and boss)
	# to be loaded via getting parent details
	# TODO: implement this when enemies have been set up
var raw_dialogue = {}
var dialogue_bubble_prefab = preload("res://scenes/dialogue_bubble/dialogue_bubble.tscn")
var timer: Timer

@export var min_dialogue_elapsed_time: float = 2.0
@export var max_dialogue_elapsed_time: float = 10.0

# TEMP NEEDS TO BE LINKED WITH OTHER SECTIONS OF CODE:
# TODO: link with other sections when I've got a good idea of what can be linked to!
var player_conditions = {
	"insanity": 50
}
var trigger = "idle"

func _ready() -> void:
	randomize()
	timer = Timer.new()
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	add_child(timer)
	
	if get_parent() is Sprite3D:
		can_speak = get_parent().can_speak
	
	if attached_to_team == Enums.Team.PLAYER:
		# load dialogue and begin timer
		raw_dialogue = DialogueProcessor._load_file(CustomResourceLoader.dialogue_path + Enums.Team.keys()[attached_to_team].to_lower() + ".json")
		if can_speak:
			timer.start(randf_range(min_dialogue_elapsed_time, max_dialogue_elapsed_time))

func _process(delta: float) -> void:
	pass

# currently all the creation code is just in this timeout method
# once i do signals, i'll move the code into a more general method
# for now this is fine though
func _on_timer_timeout() -> void:
	if can_speak:
		# get dialogue and initialise bubble
		var dialogue = DialogueProcessor._get_runtime_dialogue(raw_dialogue, trigger, player_conditions)
		_add_bubble(dialogue)
		# restart timer
		timer.start(randf_range(min_dialogue_elapsed_time, max_dialogue_elapsed_time))


func _clear_all_bubbles():
	for child in get_children():
		_remove_bubble(child)

# remove bubble once transparency is complete
# ive added this to run in this component rather than the child because I use this as my trigger
# to update all dialogue bubble positions (rather than the inefficiencies of using process())
func _remove_bubble(child):
	child.queue_free()

func _add_bubble(dialogue: String, is_system_popup: bool = false):
	if can_speak:
		var bubble = dialogue_bubble_prefab.instantiate()
		bubble.base_transparency_speed = base_transparency_speed
		
		if is_system_popup:
			_clear_all_bubbles()
			bubble._set_type(Enums.BubbleType.SYSTEM)
		
		add_child(bubble)
		bubble._set_text(dialogue)
		if attached_to_team != Enums.Team.WORLD:
			bubble.can_disappear = true
			# make component listen to the child transparency calls
			bubble.is_transparent.connect(_remove_bubble)
			_update_all_transparency_speed()

func _update_all_transparency_speed() -> void:
	var children = get_children()
	var index = 0
	for child in children:
		if child is PanelContainer:
			child._update_bubble_transparency_speed((children.size() - 1) - index)
			index += 1

func _make_all_bubbles_transparent() -> void:
	for bubble in get_children():
		if bubble is PanelContainer:
			bubble.can_disappear = true
			bubble.base_transparency_speed = base_transparency_speed
			# make component listen to the child transparency calls
			bubble.is_transparent.connect(_remove_bubble)

# chucking this stuff here so its out of the way lol
# these are just the unit tests for dialogue loading
func _debug_tests_for_linking() -> void:
	print("TESTING RUNTIME DIALOGUE:")
	print("TEST 1: Print random dialogue (using requirement bypass)")
	print(DialogueProcessor._get_runtime_dialogue(raw_dialogue, trigger, player_conditions, "hallway") + "\r\n")
	
	print("TEST 2: Room not specified")
	print(DialogueProcessor._get_runtime_dialogue(raw_dialogue, trigger, player_conditions) + "\r\n")
	
	print("TEST 3: Invalid room")
	print(DialogueProcessor._get_runtime_dialogue(raw_dialogue, trigger, player_conditions, "hell") + "\r\n")
	
	trigger = "wtf"
	print("TEST 4: Invalid trigger")
	print(DialogueProcessor._get_runtime_dialogue(raw_dialogue, trigger, player_conditions, "hallway") + "\r\n")
	
	
	print("TESTING DATING DIALOGUE:")
	# initialisation of vars:
	var current_dating_scene = []
	var next_dating_dialogue = {}
	var option = {}
	
	# first load the scene - in this case the only scene is "first_interaction"
		# it would be great to have the scenes be held in a global Enum or smth to log each dating 'scene'
	current_dating_scene = DialogueProcessor._get_dating_scene("possible_dating_dialogue", "first_interaction")
	
	# then load up your dating dialogue!
	# below are some examples of loading entries off dating_dialogue.json
	
	# dialogue 1
	next_dating_dialogue = DialogueProcessor._get_next_dating_dialogue(current_dating_scene)
	print(next_dating_dialogue["dialogue"])
	
	# dialogue 2
	next_dating_dialogue = DialogueProcessor._get_next_dating_dialogue(current_dating_scene, next_dating_dialogue)
	print(next_dating_dialogue["dialogue"])
	
	# dialogue 3
	next_dating_dialogue = DialogueProcessor._get_next_dating_dialogue(current_dating_scene, next_dating_dialogue)
	print(next_dating_dialogue["dialogue"])
	
	# attempting to run the next dialogue from dialogue 3
		# this won't work because dialogue 3 wants an option to be specified in order to set a next_id
		# uncomment the below code if you want to test this
		# this code will return an error, but Output will log details on the actual error etc.
	# next_dating_dialogue = DialogueProcessor._get_next_dating_dialogue(current_dating_scene, next_dating_dialogue)
	# print(next_dating_dialogue["dialogue"])
	
	# dialogue 4 (option 2 from dialogue 3)
	option = next_dating_dialogue["options"][1]
	next_dating_dialogue = DialogueProcessor._get_next_dating_dialogue(current_dating_scene, option)
	print(next_dating_dialogue["dialogue"])
