extends Resource
class_name BrainJarPhase

## Determines what happens after all terminals for this phase are activated
enum CompletionType {
	## Boss ignores first shot then advances to next phase
	BLOCK_SHOT_AND_ADVANCE,
	
	## Sacrifice chute becomes available. Boss becomes vulnerable after a gun is sacrificed
	SACRIFICE_THEN_DAMAGE,
	
	## Boss becomes vulnerable without requiring  sacrifice
	FINAL_VULNERABILITY,
}

## Number of randomly selected terminals required during this phase
@export var terminal_count: int = 4

## Action performed after the required terminals have been activated
@export var completion_type: CompletionType = \
	CompletionType.BLOCK_SHOT_AND_ADVANCE
