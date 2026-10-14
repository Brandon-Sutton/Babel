extends Node
## Room index and exploration progress. MAP-001 generates the index file, MAP-002 tracks
## discovery per map cell and MAP-007 computes completion.

const INDEX_PATH: String = "res://data/world_index.json"

## Parsed contents of the world index (empty until MAP-001 produces the file).
var index: Dictionary = {}
## Map cells the player has seen.
var discovered: Dictionary[Vector2i, bool] = {}


func _ready() -> void:
	load_index()


## Loads the world index if it exists.
func load_index() -> void:
	index.clear()
	if not FileAccess.file_exists(INDEX_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(INDEX_PATH))
	if parsed is Dictionary:
		index = parsed
	else:
		push_error("WorldMap: %s is not a JSON object." % INDEX_PATH)


## Marks [param cell] as discovered.
func discover_cell(cell: Vector2i) -> void:
	discovered[cell] = true


## Returns true if [param cell] has been discovered.
func is_discovered(cell: Vector2i) -> bool:
	return discovered.has(cell)
