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
	
