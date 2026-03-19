extends Node

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
	raw_dialogue = DialogueLoader._load_file(entity)
	
	print("TESTING DIALOGUE:")
	print("TEST 1: Print random dialogue (using requirement bypass)")
	print(DialogueLoader._retrieve_random_dialogue(raw_dialogue, true) + "\r\n")
	
	print("TEST 2: Print dialogue 1 (via not specifying requirements)")
	print(DialogueLoader._retrieve_random_dialogue(raw_dialogue) + "\r\n")
	
	print("TEST 3: Print dialogue 2 (via specifying room requirement)")
	print(DialogueLoader._retrieve_random_dialogue(raw_dialogue, false, "hallway") + "\r\n")
	
	print("TEST 4: Print non-random dialogue (still using requirement bypass)")
	print(DialogueLoader._retrieve_non_random_dialogue(raw_dialogue, true) + "\r\n")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
