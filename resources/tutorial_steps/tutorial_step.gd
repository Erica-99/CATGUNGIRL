class_name TutorialStep
extends Resource

@export_group("Popup Text")
@export var title: String = "PLACEHOLDER TITLE"

## Default description - always used if the other description_gamepad or 
## description_playstation don't apply or are left empty
@export_multiline var description_kbm: String = "Placeholder Description, introduce concepts here"

## shown instead of Description KBM when the player is using an xbox/generic controller
## leave empty to just reuse Description
@export_multiline var description_gamepad: String = ""

## shown instead of 'Description Gamepad' specifically for PlayStation controllers
## leave empty to just reuse Description Gamepad
@export_multiline var description_playstation: String = ""

## static task, (e.g. "walk left and right")
@export var task: String = "Whatever task the player must commit to dismiss the instruction"

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
