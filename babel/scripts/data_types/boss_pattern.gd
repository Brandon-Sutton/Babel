class_name BossPattern
extends Resource
## One attack pattern a boss can choose (BOSS-000). The boss's script performs it by
## [member id]; the PatternSequencer decides when, from these conditions.

@export var id: StringName
## Relative chance among the patterns available at that moment.
@export var weight: float = 1.0
## First phase it is used in (0 = from the start).
@export var min_phase: int = 0
## A part the pattern needs (BOSS-030): once that part is severed, it is never chosen.
@export var requires_part: StringName
## A part whose loss unlocks the pattern: it is chosen only after that part is severed.
@export var needs_severed: StringName
## Distance to the player (px) it is used within; 0 for no limit.
@export var max_range: float = 0.0
## Distance to the player (px) it needs at least.
@export var min_range: float = 0.0


## True if the pattern can be chosen in [param phase], with [param severed] parts gone
## and the player [param distance] px away.
func is_available(phase: int, severed: Dictionary[StringName, bool], distance: float) -> bool:
	if phase < min_phase:
		return false
	if not requires_part.is_empty() and severed.get(requires_part, false):
		return false
	if not needs_severed.is_empty() and not severed.get(needs_severed, false):
		return false
	if max_range > 0.0 and distance > max_range:
		return false
	return distance >= min_range
