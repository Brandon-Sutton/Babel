class_name PatternSequencer
extends RefCounted
## Chooses a boss's next pattern (BOSS-000): a weighted random pick among the patterns
## available now (phase, severed parts, range), never the same one twice in a row while
## another is available.

## The pattern picked last, or empty.
var last: StringName = &""
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(seed_value: int = -1) -> void:
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()


## The patterns of [param patterns] that can be chosen right now.
static func available(patterns: Array[BossPattern], phase: int, severed: Dictionary[StringName, bool],
		distance: float) -> Array[BossPattern]:
	var result: Array[BossPattern] = []
	for pattern: BossPattern in patterns:
		if pattern != null and pattern.is_available(phase, severed, distance) and pattern.weight > 0.0:
			result.append(pattern)
	return result


## Picks the next pattern, or null if none is available.
func pick(patterns: Array[BossPattern], phase: int, severed: Dictionary[StringName, bool],
		distance: float) -> BossPattern:
	var choices: Array[BossPattern] = available(patterns, phase, severed, distance)
	if choices.size() > 1:
		var fresh: Array[BossPattern] = []
		for pattern: BossPattern in choices:
			if pattern.id != last:
				fresh.append(pattern)
		if not fresh.is_empty():
			choices = fresh
	if choices.is_empty():
		return null
	var total: float = 0.0
	for pattern: BossPattern in choices:
		total += pattern.weight
	var roll: float = rng.randf() * total
	var chosen: BossPattern = choices[choices.size() - 1]
	for pattern: BossPattern in choices:
		roll -= pattern.weight
		if roll < 0.0:
			chosen = pattern
			break
	last = chosen.id
	return chosen
