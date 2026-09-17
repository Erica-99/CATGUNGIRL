class_name TutorialStep
extends Resource

@export_group("Popup Text")
@export var title: String = "PLACEHOLDER TITLE"
@export_multiline var description: String = "Placeholder Description, introduce concepts here"
@export var task: String = "Whatever task the player must commit to dismiss the instruction"

## shown instead of Task when the player is using a controller
## leave empty to just reuse Task
@export var task_gamepad: String = ""

## shown instead of 'Task Gamepad' specifically for PlayStation controllers 
## leave empty to just reuse Task Gamepad
@export var task_playstation: String = ""

@export_group("How This Step Completes")
enum CompletionMode {
	GAME_EVENT,   ## completes when something happens in the game (gun fires, an enemy dies, etc.)
	BUTTON_PRESS, ## completes as soon as the player presses a specific button
	MANUAL,       ## only completes when another script says so
}
@export var completion_mode: CompletionMode = CompletionMode.BUTTON_PRESS

## name of the game event that completes this step
## (e.g. shots_fired, primary_fire_used, alt_fire_used, gun_picked_up, enemy_killed)
@export var game_event_name: StringName = &""

## optional - if the event above is about a weapon, require this specific one before it counts
## (Pistol, Shotgun, Sniper, or Grapple) or Leave blank to accept any weapon
## IMPORTANT: this is case sensitive
@export var weapon_name: String = ""

## which button(s)/action(s) complete this step (e.g. "jump", or "move_left" and "move_right")
@export var buttons: Array[StringName] = []

## if true, ALL of the buttons above must be pressed at some point (in any order) before this
## step completes, if false, pressing ANY ONE of them completes it immediately
@export var require_all_buttons: bool = true
