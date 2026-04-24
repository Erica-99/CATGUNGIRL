class_name Enums


## Represents one of the teams in the game
enum Team {
	WORLD,
	PLAYER,
	LAB_STAFF,
}

## Used to refer to different damage types like normal, fire, explosive, etc. Useful for having interesting death animations.
enum DamageType {
	NORMAL,
	DECAY,
}

## Based off of the health bar, rank would affect access to moves
## and appearance of the UI (e.g. Low Health Indicator)
enum InterestRank {
	LOW, ## Names could change (e.g. HEART_BREAK)
	MEDLOW,
	MEDHIGH,
	HIGH, ##MADLY_IN_LOVE
}

## Added for gun component
enum ChargeMode {
	AUTO_FIRE,   ## right click -> charges for a fixed duration -> auto fires
	HOLD_TO_FIRE, ## hold right click -> charge builds up -> release to fire
}

enum InteractableType {
	DOOR,
	CONSOLE,
}
