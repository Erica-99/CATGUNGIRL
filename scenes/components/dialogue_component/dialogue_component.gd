extends Node

@onready var timer: Timer = $"../Timer"
@onready var mesh_instance_3d: Sprite3D = $"../.."

@export var min_dialogue_elapsed_time: float = 1.0
@export var max_dialogue_elapsed_time: float = 1.0
@export var can_speak: bool = true
@export var debug_mode: bool = false

# set variables to change on initialisation
	# entity can be: player, gun, enemy (including enemy types ie: convict, trunk, scrub and boss)
	# to be loaded via getting parent details
var entity = ""
var raw_dialogue = {}
var dialogue_bubble_prefab = preload("res://scenes/dialogue_bubble/dialogue_bubble.tscn")


# TEMP NEEDS TO BE LINKED WITH OTHER SECTIONS OF CODE:
var player_conditions = {
	"insanity": 50
}
var trigger = "idle"

func _ready() -> void:
	randomize()
	# here you would get the parent node's ID but I'm not sure if we will do it this way so I'll hardcode for now
	#entity = get_parent().{insert variable which identified parent like ID or name IDK}
	entity = "player"
	raw_dialogue = DialogueProcessor._load_file(CustomResourceLoader.dialogue_path + entity + ".json")
	timer.start(randf_range(min_dialogue_elapsed_time, max_dialogue_elapsed_time))
	
	if debug_mode:
		_debug_tests_for_linking()

func _process(delta: float) -> void:
	pass

	


func _on_timer_timeout() -> void:
	var dialogue = DialogueProcessor._get_runtime_dialogue(raw_dialogue, trigger, player_conditions)
	var bubble = dialogue_bubble_prefab.instantiate()
	add_child(bubble)
	bubble.owner = self
	bubble._set_text(dialogue)
	bubble.is_transparent.connect(_remove_bubble)
	_update_bubble_positions()
	print("my starting position is: " + str(bubble.position))
	
	timer.start(randf_range(min_dialogue_elapsed_time, max_dialogue_elapsed_time))

func _remove_bubble(child):
	child.queue_free()
	_update_bubble_positions()

# WHY THE FUCK DOES THIS MAKE A PARTICLE ACCELERATOR
# IT WAS THE FUCKING INDEX ARRGGGGG
# IF ANYONE TOUCHES THIS SHIT ILL RIP OFF BOTH YOUUR ARMS
func _update_bubble_positions():
	var children = get_children()
	print(children.size())
	if children.size() > 1:
		var index = 0
		for child in children:
			print("prior to change, my (index " + str(index) + ") position was: " + str(child.position))
			child._set_position_off_index((children.size() - 1) - index)
			print("my new position (index " + str(index) + ") is: " + str(child.position))
			index += 1
	else:
		children[0]._set_position_off_index(0)

# chucking this stuff here so its out of the way lol
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
