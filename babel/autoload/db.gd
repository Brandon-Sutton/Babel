extends Node
## Game data registry. Loads every resource under [code]res://data/[/code] that has an
## [code]id[/code] property and indexes it by that id. INV-002 adds icon validation and
## typed lookups on top of this.

const DATA_ROOT: String = "res://data"

var _entries: Dictionary[StringName, Resource] = {}


func _ready() -> void:
	reload()


## Rebuilds the index from disk. Returns the number of duplicate ids found (0 = valid).
func reload() -> int:
	_entries.clear()
	var duplicates: int = 0
	for path: String in FileScan.list_files(DATA_ROOT, [".tres", ".res"]):
		var res: Resource = load(path)
		if res == null or not ("id" in res):
			continue
		var id: StringName = res.get("id")
		if id.is_empty():
			continue
		if _entries.has(id):
			push_error("Db: duplicate id '%s' in %s and %s" % [id, _entries[id].resource_path, path])
			duplicates += 1
			continue
		_entries[id] = res
	return duplicates


## Returns the entry with [param id], or [code]null[/code] if there is none.
func get_entry(id: StringName) -> Resource:
	return _entries.get(id)


## Returns true if an entry with [param id] exists.
func has_entry(id: StringName) -> bool:
	return _entries.has(id)


## Returns every indexed id.
func ids() -> Array[StringName]:
	return _entries.keys()
