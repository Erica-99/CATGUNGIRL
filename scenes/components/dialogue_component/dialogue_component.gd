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
		print("TESTING DIALOGUE:")
		print("TEST 1: Print random dialogue (using requirement bypass)")
		print(DialogueProcessor._retrieve_dialogue(raw_dialogue, trigger, player_conditions, "hallway", true) + "\r\n")
		
		print("TEST 2: Room not specified")
		print(DialogueProcessor._retrieve_dialogue(raw_dialogue, trigger, player_conditions) + "\r\n")
		
		print("TEST 3: Invalid room")
		print(DialogueProcessor._retrieve_dialogue(raw_dialogue, trigger, player_conditions, "hell") + "\r\n")
		
		trigger = "wtf"
		print("TEST 4: Invalid trigger")
		print(DialogueProcessor._retrieve_dialogue(raw_dialogue, trigger, player_conditions, "hallway") + "\r\n")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
