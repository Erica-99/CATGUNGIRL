extends CanvasLayer

## charge bar UI (connect to GunComponent's signals to show charge progress)

@onready var bar_container = $ChargeBarContainer
@onready var fill = $ChargeBarContainer/Fill
@onready var label = $ChargeBarContainer/Label


func _ready() -> void:
	bar_container.visible = false


## connect GunComponent.charge_progress_changed to this
func on_charge_progress(progress: float) -> void:
	bar_container.visible = true
	# scale the fill bar width based on progress
	fill.scale.x = progress
	label.text = "CHARGING... %d%%" % int(progress * 100)


## connect GunComponent.charge_ended to this
func on_charge_ended() -> void:
	bar_container.visible = false


func _on_gun_component_charge_ended() -> void:
	pass # replace later
