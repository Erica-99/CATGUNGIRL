extends PanelContainer

# references
@onready var rich_text_label: RichTextLabel = $RichTextLabel

# export vars
@export var linear_transparency_decrease: float = 0.5
@export var textbox_colour: Color = Color.BLACK

# runtime vars
var rate_of_transparency: float = 0
var can_disappear: bool = false
var base_transparency_speed: float = 4.0
@export var type = Enums.BubbleType.RUNTIME
var typewriter_tween: Tween

# consts
const MAX_OPACITY: float = 1.0
const VERT_OFFSET_RUNTIME: float = 55

# signals
signal is_transparent

func _ready() -> void:
	rich_text_label.add_theme_color_override("default_color", textbox_colour)

	rate_of_transparency = MAX_OPACITY / (base_transparency_speed * 60)
	
	if type == Enums.BubbleType.POPUP:
		rich_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		rich_text_label.size_flags_vertical = Control.SIZE_EXPAND
		
	#elif type == Enums.BubbleType.RUNTIME:
		#var new_background = StyleBoxTexture.new()
		#new_background.texture = load("res://resources/dialogue/slanted_dialogue.png")
		#add_theme_stylebox_override("panel", new_background)

func _process(delta: float) -> void:
	if can_disappear:
		# reduce modulate for itself and children by rate of transparency
		modulate.a -= rate_of_transparency
		# emit signal to ask for deletion if 0 transparency is hit
		if modulate.a < 0:
			emit_signal("is_transparent", self)
	
# function sets text to certain value - if display_as_typewriter and typewriter_duration are filled, a typewriter effect is applied
# also shake too - change the params as you need
func _set_text(text: String, display_as_typewriter: bool = false, typewriter_duration: float = 0.0) -> void:
	rich_text_label.text = text
	if display_as_typewriter:
		# attach shake flags - depending on other people's opinions, might change this up to use param calls or constants?
		rich_text_label.text = text
		rich_text_label.visible_ratio = 0.0
		typewriter_tween = create_tween()
		typewriter_tween.tween_property(rich_text_label, "visible_ratio", 1.0, typewriter_duration)

# kills active tween and sets visibility back to 1
func _kill_tween() -> void:
	if typewriter_tween.is_valid():
		typewriter_tween.kill()
		rich_text_label.visible_ratio = 1.0

func _set_type(type: Enums.BubbleType) -> void:
	type = type
	#if type == Enums.BubbleType.SYSTEM:
		#set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		
		
func _update_bubble_transparency_speed(index: int) -> void:
	var new_speed = base_transparency_speed - (index * linear_transparency_decrease)
	if new_speed < 0.0:
		new_speed = 0.0
	# update rate
	rate_of_transparency = MAX_OPACITY / (new_speed * 60)
