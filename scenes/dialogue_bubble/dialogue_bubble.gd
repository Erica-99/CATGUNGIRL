extends PanelContainer

# references
@onready var rich_text_label: RichTextLabel = $RichTextLabel

# export vars
@export var linear_transparency_decrease: float = 0.5

# consts
const max_opacity: int = 1.0

# runtime vars
var centred_position: Vector2 = Vector2.ZERO
var rate_of_transparency: float = 0
var can_disappear: bool = false
var base_transparency_speed: float = 4.0

# signals
signal is_transparent

func _ready() -> void:
	# set initial values for runtime vars
	centred_position = _get_position_around_origin()
	rate_of_transparency = max_opacity / (base_transparency_speed * 60)

func _process(delta: float) -> void:
	if can_disappear:
		# reduce modulate for itself and children by rate of transparency
		modulate.a -= rate_of_transparency
		# emit signal to ask for deletion if 0 transparency is hit
		if modulate.a < 0:
			emit_signal("is_transparent", self)
	
# set text lmao
func _set_text(text: String) -> void:
	rich_text_label.text = text

# god i hate the name of this function - pls rename it if you think of smth better
# all this does is get the offset coordinates so to centre the bubble around its original position
func _get_position_around_origin() -> Vector2:
	var origin_position = position
	origin_position.x -= size.x / 2
	origin_position.y -= size.y / 2
	return origin_position

# update position and transparency based off index of child
# the index which is passed in is the reverse of the child list!
func _update_off_index(index: int = 0) -> void:
	# get transparency speed
	var new_speed = base_transparency_speed - (index * linear_transparency_decrease)
	if new_speed < 0.0:
		new_speed = 0.0
	# update rate
	rate_of_transparency = max_opacity / (new_speed * 60)
	# update ycoord
	position.y = centred_position.y - (50 * index)
