extends Node3D
class_name BrainSpiderVisuals

@onready var brain_spider: BrainSpider = $".."
@onready var body_visual: AnimatedSprite3D = $Visuals/AnimatedSprite3D
@onready var explosion_visual: AnimationPlayer = $Visuals/Explosion/Explosion/explode_anims


func _ready() -> void:
	show_spider_visual()

func show_spider_visual() -> void:
	body_visual.visible = true


func show_explosion_visual() -> void:
	body_visual.visible = false
	explosion_visual.play("Explode")
	
	
func is_explosion_playing() -> bool:
	return explosion_visual.is_playing()

func apply_surface_rotation() -> void:
	if brain_spider.spider_mode == BrainSpider.SpiderMode.FLOOR:
		rotation.z = 0.0
		return
	
	match brain_spider.surface_type:
		BrainSpider.SurfaceType.CEILING:
			rotation.z = PI
		BrainSpider.SurfaceType.LEFT_WALL:
			rotation.z = -PI / 2.0
		BrainSpider.SurfaceType.RIGHT_WALL:
			rotation.z = PI / 2.0

func face_direction(direction: float) -> void:
	if direction == 0.0:
		return
	
	var should_flip: bool = direction < 0.0
	
	if brain_spider.spider_mode == BrainSpider.SpiderMode.WALL_CEILING and brain_spider.surface_type == BrainSpider.SurfaceType.CEILING:
		should_flip = !should_flip
	
	body_visual.flip_h = should_flip
