extends Node

# references
@onready var timer: Timer = $"../Timer"
@onready var mesh_instance_3d: Sprite3D = $"../.."
@onready var dialogue_renderer: Sprite3D = $"../.."

# set variables to change on initialisation
	# entity can be: player, gun, enemy (including enemy types ie: convict, trunk, scrub and boss)
	# to be loaded via getting parent details
	# TODO: implement this when enemies have been set up
var entity = ""
var raw_dialogue = {}
var dialogue_bubble_prefab = preload("res://scenes/dialogue_bubble/dialogue_bubble.tscn")


# TEMP NEEDS TO BE LINKED WITH OTHER SECTIONS OF CODE:
# TODO: link with other sections when I've got a good idea of what can be linked to!
var player_conditions = {
	"insanity": 50
}
var trigger = "idle"

func _ready() -> void:
	randomize()
	
	if dialogue_renderer._is_attached_to_entity():
		# here you would get the parent node's ID but I'm not sure if we will do it this way so I'll hardcode for now
		#entity = get_parent().{insert variable which identified parent like ID or name IDK}
		# TODO: do at a later stage
		entity = "player"
		# load dialogue and begin timer
		raw_dialogue = DialogueProcessor._load_file(CustomResourceLoader.dialogue_path + entity + ".json")
		if dialogue_renderer.can_speak:
			timer.start(randf_range(dialogue_renderer.min_dialogue_elapsed_time, dialogue_renderer.max_dialogue_elapsed_time))
		
		# this debug mode is only for if u want to see how the calls work
		# for like implementing dialogue calls elsewhere
		if dialogue_renderer.debug_mode:
			_debug_tests_for_linking()

func _process(delta: float) -> void:
	pass

# currently all the creation code is just in this timeout method
# once i do signals, i'll move the code into a more general method
# for now this is fine though
func _on_timer_timeout() -> void:
	if dialogue_renderer.can_speak:
		# get dialogue and initialise bubble
		var dialogue = DialogueProcessor._get_runtime_dialogue(raw_dialogue, trigger, player_conditions)
		_add_bubble(dialogue)
		# restart timer
		timer.start(randf_range(dialogue_renderer.min_dialogue_elapsed_time, dialogue_renderer.max_dialogue_elapsed_time))

# remove bubble once transparency is complete
# ive added this to run in this component rather than the child because I use this as my trigger
# to update all dialogue bubble positions (rather than the inefficiencies of using process())
func _remove_bubble(child):
	child.queue_free()
	_update_bubble_positions()

func _add_bubble(dialogue: String):
	var bubble = dialogue_bubble_prefab.instantiate()
	bubble.base_transparency_speed = dialogue_renderer.base_transparency_speed
	add_child(bubble)
	bubble._set_text(dialogue)
	if dialogue_renderer._is_attached_to_entity():
		bubble.can_disappear = true
		# make component listen to the child transparency calls
		bubble.is_transparent.connect(_remove_bubble)
	# set initial position
	_update_bubble_positions()

# notably this section, if you mess with the indexes and be an idiot (like me) you can make the
# dialogue appear and move similar to how a particle accelerator operates
# just dont touch this code lmfao
func _update_bubble_positions() -> void:
	var children = get_children()
	if children.size() > 1:
		var index = 0
		for child in children:
			child._update_off_index((children.size() - 1) - index)
			index += 1
	else:
		children[0]._update_off_index()
		

func _make_all_bubbles_transparent() -> void:
	for bubble in get_children():
		bubble.can_disappear = true
		bubble.base_transparency_speed = dialogue_renderer.base_transparency_speed
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
	current_dating_scene = DialogueProcessor._get_dating_scene("first_interaction")
	
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
