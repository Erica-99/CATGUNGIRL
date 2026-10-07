extends Resource
class_name BrainJarPhase

## Determines what happens after all terminals for this phase are activated
enum CompletionType {
	## Boss takes damage, heals, then advances to next phase
	DAMAGE_HEAL_AND_ADVANCE,
	
	## Sacrifice chute becomes available. Sacrificing a gun damages the boss and advances to next phase
	SACRIFICE_DAMAGE_AND_ADVANCE,
	
	## Boss becomes vulnerable without requiring  sacrifice
	FINAL_VULNERABILITY,
}

## Number of randomly selected terminals required during this phase
@export var terminal_count: int = 4

## Action performed after the required terminals have been activated
@export var completion_type: CompletionType = \
	CompletionType.DAMAGE_HEAL_AND_ADVANCE
