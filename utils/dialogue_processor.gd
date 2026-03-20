extends Node
class_name DialogueProcessor

static func _load_file(file_path) -> Dictionary:
	var dialogue_file = FileAccess.open(file_path, FileAccess.READ)
	return JSON.parse_string(dialogue_file.get_as_text())
	
# processing function to reduce repetition - gets dialogue from an already filtered list
	# valid_dialogue_list = dialogue entries the entity can use currently
static func _get_dialog(valid_dialogue_list) -> String:
	print(valid_dialogue_list)
	var selected_dialogue = "Could not find a valid dialogue entry."
	if valid_dialogue_list.size() > 0:
		# get random dialogue
		var rand_index = randi_range(0, valid_dialogue_list.size() - 1)
		selected_dialogue = valid_dialogue_list[rand_index]["dialogue"]
	
	return selected_dialogue

# checks two arrays to see if condition of entity contains requirements
	# requirements = dict from JSON dialogue entry
	# condition = entity condition
static func _check_for_condition_mismatch(requirements, conditions):
	for requirement in requirements:
		if !conditions.has(requirement) || conditions[requirement] != requirements[requirement]:
			return false
	return true
	
# retrieves dialogue from JSON
# uses room, trigger and conditions to filter
	# room = what room type the game is in right now (hallway/encounter/boss_room)
	# trigger = action entity just took
	# conditions = state of entity (movement/insanity/health status etc.)
static func _retrieve_dialogue(dialogue_dict, trigger, conditions, room = "any", bypass_filter = false) -> String:
	var valid_dialogue_list = []
	var room_filtered_dict = {"any": dialogue_dict["any"]}
	if dialogue_dict.has(room) && room != "any":
		room_filtered_dict = { room: dialogue_dict[room], "any": dialogue_dict["any"] }
	elif !dialogue_dict.has(room):
		return "Room does not exist."
	
	# loop room 
	for room_dict in room_filtered_dict:
		var trigger_filtered_dict = []
		
		if room_filtered_dict[room_dict].has(trigger):
			trigger_filtered_dict = room_filtered_dict[room_dict][trigger]
		
			for dialogue_option in trigger_filtered_dict:
				var requirements_met = true
				
				if dialogue_option["requirement"].size() != 0:
					requirements_met = _check_for_condition_mismatch(dialogue_option["requirement"], conditions)
				
				if requirements_met || bypass_filter:
					valid_dialogue_list.append(dialogue_option)
	
	return _get_dialog(valid_dialogue_list)
