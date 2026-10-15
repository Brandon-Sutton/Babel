class_name Inventory
extends RefCounted
## Items the player carries but isn't wearing, as counts by item id (INV-003).
## Equipped items live in PlayerStats.equipped; Game.equip() moves items between them.

signal changed

var _counts: Dictionary[StringName, int] = {}


func add(id: StringName, count: int = 1) -> void:
	if count <= 0:
		return
	_counts[id] = _counts.get(id, 0) + count
	changed.emit()


## Removes up to [param count]; returns false if there weren't that many.
func remove(id: StringName, count: int = 1) -> bool:
	var have: int = _counts.get(id, 0)
	if have < count:
		return false
	if have == count:
		_counts.erase(id)
	else:
		_counts[id] = have - count
	changed.emit()
	return true


func count(id: StringName) -> int:
	return _counts.get(id, 0)


## Item ids carried, in the order they were first added.
func ids() -> Array[StringName]:
	return _counts.keys()


## All counts, for saving.
func to_dict() -> Dictionary:
	var out: Dictionary = {}
	for id: StringName in _counts:
		out[String(id)] = _counts[id]
	return out


## Replaces the contents from a saved dictionary.
func load_dict(data: Dictionary) -> void:
	_counts.clear()
	for key: Variant in data:
		_counts[StringName(str(key))] = int(data[key])
	changed.emit()
