extends CanvasLayer

class_name LoadingScreen

signal loading_screen_ready

@export var animation_player: AnimationPlayer
@onready var progress_bar: ProgressBar = $Panel/HorizontalLayout/VertDisplay/ProgressBar
@onready var meme_image: TextureRect = $Panel/HorizontalLayout/MemeImage

var next_scene: String = ""

# this is awful but i am tired and i will fix later
const image_1 = preload("res://scenes/ui/menu_screens/loading_screen/meme_images/5_eva.jpg")
const image_2 = preload("res://scenes/ui/menu_screens/loading_screen/meme_images/1000_yard_stare.png")
const image_3 = preload("res://scenes/ui/menu_screens/loading_screen/meme_images/4000.jpg")
const image_4 = preload("res://scenes/ui/menu_screens/loading_screen/meme_images/absolute_cinema.png")
const image_5 = preload("res://scenes/ui/menu_screens/loading_screen/meme_images/alone_again_lecture.jpg")
const image_6 = preload("res://scenes/ui/menu_screens/loading_screen/meme_images/aughhhh.png")
const image_7 = preload("res://scenes/ui/menu_screens/loading_screen/meme_images/couch_beer.png")

const image_arr: Array = [
	image_1,
	image_2,
	image_3,
	image_4,
	image_5,
	image_6,
	image_7,
]
 
func _ready() -> void:
	meme_image.texture = image_arr[randi_range(0, len(image_arr) - 1)]
	await animation_player.animation_finished
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
