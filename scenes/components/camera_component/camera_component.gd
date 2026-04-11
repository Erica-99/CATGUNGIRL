extends Camera3D

# references
@onready var player: CharacterBody3D = $".."

# export vars
@export var pan_camera: bool = true
@export var pan_offset: float = 1.0
@export var pan_speed: float = 5.0
# pan limit x and y sets the maximum - change this as needed
@export var pan_limit_x: float = 2.0
@export var pan_limit_y: float = 0.4

var min_clamp_position: Vector3 = Vector3.ZERO
var max_clamp_position: Vector3 = Vector3.ZERO
var original_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	original_position = position
	# set minimum clamp position
	min_clamp_position.x = position.x + -pan_limit_x
	min_clamp_position.y = position.y + -pan_limit_y
	# set maximum clamp position
	max_clamp_position.x = position.x + pan_limit_x
	max_clamp_position.y = position.y + pan_limit_y

func _process(delta: float) -> void:
	if pan_camera:
		# i was going to use raycasting for getting mouse position - but this is kinda redundant since we only need the 2D plane of the mouse position
		# so instead i've used the viewpoint and 2D mouse position for these calculations
		# replace this code if you found a more efficient way to do this pls
		
		var mouse_position = get_viewport().get_mouse_position()
		# viewport needs to be set as a Vector2 because it is a Vector2i by default
		var viewport = Vector2(get_viewport().size)
		# gets position relative to viewport size (range -1 to +1 for both x and y mouse position coords)
		var relative_mouse_position = (mouse_position / viewport) * 2 - Vector2(1.0, 1.0)
		
		# set camera position to the original initialised position for smoother panning
		var camera_mouse_position = original_position
		var is_camera_panning: bool = false
		# set x position if in the outer 75% +- x coords region
		if relative_mouse_position.x > 0.75 or relative_mouse_position.x < -0.75:
			camera_mouse_position.x = position.x + relative_mouse_position.x * pan_offset
			is_camera_panning = true
		
		# set y position if in the outer 75% +- y coords region
		if relative_mouse_position.y > 0.75 or relative_mouse_position.y < -0.75:
			camera_mouse_position.y = position.y - relative_mouse_position.y * pan_offset
			is_camera_panning = true
	
		if is_camera_panning:
			# smooth pan to position
			position = position.lerp(camera_mouse_position, pan_speed * delta)
			
			# clamp https://docs.godotengine.org/en/3.0/classes/class_@gdscript.html?highlight=clamp#class-gdscript-clamp
			position.x = clamp(position.x, min_clamp_position.x, max_clamp_position.x)
			position.y = clamp(position.y, min_clamp_position.y, max_clamp_position.y)
		else:
			position = position.lerp(original_position, pan_speed * delta)
