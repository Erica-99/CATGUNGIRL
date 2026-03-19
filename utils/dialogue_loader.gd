extends Node
class_name DialogueLoader

static func _load_file(entity_type) -> Dictionary:
	var dialogue_json_path = "res://resources/dialogue/runtime.json"
	var dialogue_file = FileAccess.open(dialogue_json_path, FileAccess.READ)
	return JSON.parse_string(dialogue_file.get_as_text())[entity_type]
	
	
# TODO: remove dev_bypass later
static func _retrieve_random_dialogue(dialogue_dict, dev_bypass = false, room_requirement = "none", status_requirement = "none") -> String:
	var filtered_dialogue_dict = dialogue_dict["random_dialogue"]
	var valid_dialogue_list = []
	var selected_dialogue = "Could not find a valid dialogue entry when searching with the current tags..."
	
	for dialogue_option in filtered_dialogue_dict:
		if (dialogue_option["room_requirement"] == room_requirement && dialogue_option["status_requirement"] == status_requirement) || dev_bypass:
			valid_dialogue_list.append(dialogue_option)
	
	if valid_dialogue_list.size() > 0:
		var rand_index = randi_range(0, valid_dialogue_list.size() - 1)
		selected_dialogue = valid_dialogue_list[rand_index]["dialogue"]
	
	return selected_dialogue
	
