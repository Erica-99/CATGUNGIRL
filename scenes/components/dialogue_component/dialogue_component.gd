extends Node

@export var dialogue_file: String = ""
@export var can_speak: bool = true

# set variables to change on initialisation
	# entity can be: player, gun, enemy (including enemy types ie: convict, trunk, scrub and boss)
	# to be loaded via getting parent details
var entity = ""
var raw_dialogue = {}

func _ready() -> void:
	randomize()
	# here you would get the parent node's ID but I'm not sure if we will do it this way so I'll hardcode for now
	#entity = get_parent().{insert variable which identified parent like ID or name IDK}
	entity = "player"
	raw_dialogue = DialogueProcessor._load_file(dialogue_file)
	
	var player_conditions = {
		"insanity": 50
	}
	var trigger = "idle"
	
	if can_speak:
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
		#next_dating_dialogue = DialogueProcessor._get_next_dating_dialogue(current_dating_scene, next_dating_dialogue)
		#print(next_dating_dialogue["dialogue"])
		
		# dialogue 4 (option 2 from dialogue 3)
		option = next_dating_dialogue["options"][1]
		next_dating_dialogue = DialogueProcessor._get_next_dating_dialogue(current_dating_scene, option)
		print(next_dating_dialogue["dialogue"])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
