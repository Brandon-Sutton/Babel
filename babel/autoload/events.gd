extends Node
## Global signal bus for notices that cross system boundaries.
## Signals within a single scene connect directly instead of going through here.

@warning_ignore_start("unused_signal")

## A room finished loading and the player is inside it.
signal room_entered(room_id: StringName)
## An enemy died. [param position] is in global coordinates.
signal enemy_killed(enemy_id: StringName, position: Vector2)
## The player obtained an item, relic or ability.
signal item_acquired(item_id: StringName, count: int)
## A boss was defeated for the first time.
signal boss_defeated(boss_id: StringName)
## A persistent world flag changed (see [code]Game.set_flag()[/code]).
signal flag_set(flag: StringName, value: bool)
## The player's HP reached zero.
signal player_died
## Show a short on-screen notice, e.g. a relic's name and what it does.
signal notice(title: String, detail: String)
## Elam entered a secret area for the first time (WLD-006); [param key] is its world
## flag. The map (MAP-009) and completion % (MAP-007) listen for it.
signal secret_found(key: StringName)
