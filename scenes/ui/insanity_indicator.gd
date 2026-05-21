extends HBoxContainer

@export_category("Insanity Sprites")
@export var sprite_list : Array[AnimatedSprite2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.connect("insanity_changed",_on_insanity_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_insanity_changed(prev_insanity: int, new_insanity: int) -> void:
	for i in range(len(sprite_list)):
		if len(sprite_list) - i <= new_insanity:
			if sprite_list[i].animation != "broken":
				sprite_list[i].play("broken")
