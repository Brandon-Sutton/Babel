extends Node
## Run state for the current playthrough: persistent world flags, abilities, play time.
## WLD-013 (flag persistence), REL-002 (ability gating) and SAV-001 (saving) build on this.

## One-time world state, keyed "<room_id>/<node_name>" or by story beat.
var flags: Dictionary[StringName, bool] = {}
## Abilities granted by relics, e.g. &"double_jump".
var abilities: Dictionary[StringName, bool] = {}
## Seconds played in this run (stops while the game is paused).
var play_time: float = 0.0


func _process(delta: float) -> void:
	play_time += delta


## Sets a world flag and announces it on [code]Events.flag_set[/code].
func set_flag(flag: StringName, value: bool = true) -> void:
	flags[flag] = value
	Events.flag_set.emit(flag, value)


## Returns the flag's value; unknown flags are false.
func is_flag(flag: StringName) -> bool:
	return flags.get(flag, false)


## Returns true if the player owns [param ability].
func has_ability(ability: StringName) -> bool:
	return abilities.get(ability, false)


## Grants [param ability] to the player.
func grant_ability(ability: StringName) -> void:
	abilities[ability] = true


## Clears all run state for a new game.
func reset() -> void:
	flags.clear()
	abilities.clear()
	play_time = 0.0
