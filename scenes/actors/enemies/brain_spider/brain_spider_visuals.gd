extends Node3D
class_name BrainSpiderVisuals

@onready var brain_spider: BrainSpider = $".."
@onready var body_visual: AnimatedSprite3D = $Visuals/AnimatedSprite3D
@onready var explosion_visual: AnimatedSprite3D = $Visuals/ExplosionVisual

func _ready() -> void:
	show_spider_visual()

func show_spider_visual() -> void:
	body_visual.visible = true
	explosion_visual.visible = false

func show_explosion_visual() -> void:
	body_visual.visible = false
	explosion_visual.visible = true
	explosion_visual.frame = 0
	explosion_visual.play("default")

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
