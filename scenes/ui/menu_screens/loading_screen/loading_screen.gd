extends CanvasLayer

class_name LoadingScreen

@onready var progress_bar: ProgressBar = $Panel/HorizontalLayout/VertDisplay/ProgressBar
@onready var meme_image: TextureRect = $Panel/HorizontalLayout/MemeImage
@onready var gigi_jumpscare: TextureRect = $Panel/GigiJumpscare

@export var animation_player: AnimationPlayer

#i couldnt find a way to extract files from a directory reference - might be possible if we change the file names to "image_1.jpg" etc
# for now this is ok, but if we want to expand to more images, then we should fix it
const image_arr: Array = [
	preload("res://scenes/ui/menu_screens/loading_screen/meme_images/5_eva.jpg"),
	preload("res://scenes/ui/menu_screens/loading_screen/meme_images/1000_yard_stare.png"),
	preload("res://scenes/ui/menu_screens/loading_screen/meme_images/4000.jpg"),
	preload("res://scenes/ui/menu_screens/loading_screen/meme_images/absolute_cinema.png"),
	preload("res://scenes/ui/menu_screens/loading_screen/meme_images/alone_again_lecture.jpg"),
	preload("res://scenes/ui/menu_screens/loading_screen/meme_images/aughhhh.png"),
	preload("res://scenes/ui/menu_screens/loading_screen/meme_images/couch_beer.png"),
]

# variables toggled during instantiation (set them where this loading_screen.tscn is initialised in another node)
var next_scene: String = ""
var run_in_background: bool = false
var gigi_jumpscare_visible: bool = false

signal loading_complete()
 
func _ready() -> void:
	# lets the pause menu know a load is in progress
	add_to_group("loading_screen")
	
	# set values from instantiation
	meme_image.texture = image_arr[randi_range(0, len(image_arr) - 1)]
	gigi_jumpscare.visible = gigi_jumpscare_visible
	
	# if run_in_background is active, make canvas not visible (load in background)
	visible = !run_in_background
	
	await animation_player.animation_finished
	
	# erase all projectiles
	# this is done because the missile entity crashes if it cannot find a player (of which would have died)
	get_tree().call_group("projectiles", "queue_free")
	
	#loading_screen_ready.emit()
	if next_scene != null:
		# loads next scene
		ResourceLoader.load_threaded_request(next_scene)
	else:
		print("Attempted to load null scene. Please provide loading screen with a valid scene on initialisation.")

# Used to track the percentage of the load.
# TODO: if we want to add a loading bar use this
#func _on_progress_changed(new_value: float) -> void:
	#pass

# Happens when the scene has been loaded and switch to.
# Reverses loading screen animation to fade out
func _on_load_finished() -> void:
	var scene = ResourceLoader.load_threaded_get(next_scene)
	get_tree().change_scene_to_packed(scene)
	loading_complete.emit()
	animation_player.play_backwards()
	await animation_player.animation_finished
	queue_free()

# just watch the below vid for info on this shit working
# reference: https://www.youtube.com/watch?v=8tVyHgjzPJI

func _process(_delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(next_scene, progress)
	progress_bar.value = progress[0] * 100
	
	if progress[0] == 1:
		_on_load_finished()
