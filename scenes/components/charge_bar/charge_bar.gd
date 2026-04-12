extends CanvasLayer

## charge bar UI (connect to GunComponent's signals to show charge progress)

@onready var bar_container = $ChargeBarContainer
@onready var fill = $ChargeBarContainer/Fill
@onready var label = $ChargeBarContainer/Label


func _ready() -> void:
	bar_container.visible = false


func on_charge_progress(progress: float) -> void:
	print("charge bar received progress: ", progress)
	bar_container.visible = true
	# scale the fill bar width based on progress
	fill.scale.x = progress
	label.text = "CHARGING... %d%%" % int(progress * 100)


func on_charge_ended() -> void:
	print("charge bar received ended")
	bar_container.visible = false
