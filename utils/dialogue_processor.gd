extends Node
class_name DialogueProcessor

static func _load_file(file_path) -> Dictionary:
	var dialogue_file = FileAccess.open(file_path, FileAccess.READ)
	return JSON.parse_string(dialogue_file.get_as_text())
	
# processing function to reduce repetition - gets dialogue from an already filtered list
	# valid_dialogue_list = dialogue entries the entity can use currently
static func _get_random_dialog(valid_dialogue_list) -> String:
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
	
# retrieves runtime dialogue from JSON
# uses room, trigger and conditions to filter
	# room = what room type the game is in right now (hallway/encounter/boss_room)
	# trigger = action entity just took
	# conditions = state of entity (movement/insanity/health status etc.)
static func _get_runtime_dialogue(dialogue_dict, trigger, conditions, room = "any")	 -> String:
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
				
				if requirements_met:
					valid_dialogue_list.append(dialogue_option)
	
	return _get_random_dialog(valid_dialogue_list)
	
# gets the dating scene
# passes in scene_name
	# scene_name = identifier for a certain scene
static func _get_dating_scene(filename: String, scene_name: String) -> Array:
	# below are the old calls - this was replaced as the length of dates are longer than i expected lol
	#var dialogue_file = _load_file("res://resources/dialogue/dating_dialogue.json")
	#return dialogue_file[scene_name]
	
	var dialogue_file = _load_file(filename + ".json")
	return dialogue_file[scene_name]
	
# gets next dating dialogue from JSON
# passes in dialogue_array and current_dialogue
	# dialogue_array = all dialogue corresponding to the current scene
	# current_dialogue = the current active dialogue dictionary
static func _get_next_dating_dialogue(dialogue_array: Array, current_dialogue: Dictionary = {}) -> Dictionary:
	# check if previous_dialogue param is filled or empty
	if !current_dialogue.is_empty():
		var next_id = current_dialogue["next_id"]
		# loop all dialogue in current scene
		for dialogue in dialogue_array:
			if dialogue["id"] == next_id:
				return dialogue
		
		if next_id == "" && current_dialogue["has_options"]:
			print("This dialogue entry must have an option selected. Pass in the option from 'options' selected.")
		else:
			print("No dialogue entry matching the next_id of: '" + next_id + "' could be found in the current scene.")
		return {}
		
	else:
		# return the first dialogue entry in scene
		return dialogue_array[0]
