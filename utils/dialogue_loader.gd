extends Node
class_name DialogueLoader

static func _load_file(entity_type) -> Dictionary:
	var dialogue_json_path = "res://resources/dialogue/runtime.json"
	var dialogue_file = FileAccess.open(dialogue_json_path, FileAccess.READ)
	return JSON.parse_string(dialogue_file.get_as_text())[entity_type]
	
# processing function to reduce repetition - gets dialogue from an already filtered list
static func _get_dialog(valid_dialogue_list) -> String:
	var selected_dialogue = "Could not find a valid dialogue entry when searching with the current tags..."
	if valid_dialogue_list.size() > 0:
		var rand_index = randi_range(0, valid_dialogue_list.size() - 1)
		selected_dialogue = valid_dialogue_list[rand_index]["dialogue"]
	
	return selected_dialogue
	
# TODO: remove dev bypass
static func _retrieve_random_dialogue(dialogue_dict, dev_bypass = false, room_requirement = "none", status_requirement = "none") -> String:
	var filtered_dialogue_dict = dialogue_dict["random_dialogue"]
	var valid_dialogue_list = []
	
	for dialogue_option in filtered_dialogue_dict:
		if (dialogue_option["room_requirement"] == room_requirement && dialogue_option["status_requirement"] == status_requirement) || dev_bypass:
			valid_dialogue_list.append(dialogue_option)
	
	return _get_dialog(valid_dialogue_list)
	
# I HATE NAMING FUNCTIONS AAAA
# TODO: remove dev bypass
static func _retrieve_non_random_dialogue(dialogue_dict, dev_bypass = false, source = "none") -> String:
	dialogue_dict.erase("random_dialogue")
	var filtered_dialogue_dict = dialogue_dict
	var valid_dialogue_list = []
	
	# THIS CODE FUCKING SUCKS HOLY FUCK
	# multiple for loops <3
	# should be loaded once into a valid short dict and then go from there perchance idk lmfao
	for dialog_dict_entry in filtered_dialogue_dict:
		var dialog_header = filtered_dialogue_dict[dialog_dict_entry]
		for dialogue_option in dialog_header:
			if dialogue_option["source"] == source || dev_bypass:
				valid_dialogue_list.append(dialogue_option)
	
	return _get_dialog(valid_dialogue_list)
	
