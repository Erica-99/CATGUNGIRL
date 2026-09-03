extends State

var actor: CharacterBody3D
var anim: AnimationPlayer

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]

func enter() -> void:
	actor.action_pending = false
	#Allow for animation interrupts
	anim.stop()
	print(str(actor.get_path()) + " is doing their execute.")
	anim.play("Execute")
	# Await animation finish when animation is implemented
	await get_tree().create_timer(5.0).timeout
	SceneLoader._load_scene(get_tree().current_scene.scene_file_path)
	
