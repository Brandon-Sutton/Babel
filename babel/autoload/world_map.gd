extends Node
## The world map's data and exploration (MAP-001, MAP-002, MAP-009, first pass of
## MAP-007). The index (data/world_index.json, built by tools/world/build_world_index.gd)
## lists every map cell (one screen, 640×360 px) of every room and secret area, and the
## openings between neighbouring cells. While the game runs, the cell Elam stands in is
## marked discovered; SaveSystem stores the discovered cells. The map screen (MAP-003)
## draws all of it.

const INDEX_PATH: String = "res://data/world_index.json"
const CELL_SIZE: Vector2 = Vector2(640, 360)

## The room entry ({id, scene, region, secret, origin, cells}) of every indexed cell.
var cells: Dictionary[Vector2i, Dictionary] = {}
## Map cells Elam has been in.
var discovered: Dictionary[Vector2i, bool] = {}
## Elam's cell and where he stands inside it (0..1 on each axis), for the map's marker.
var player_cell: Vector2i = Vector2i.ZERO
var player_offset: Vector2 = Vector2(0.5, 0.5)
## False until Elam has been seen in a room.
var has_player: bool = false

var _openings: Dictionary[String, bool] = {}
var _origins: Dictionary[String, Vector2i] = {}


func _ready() -> void:
	load_index()


## Loads the world index if it exists.
func load_index() -> void:
	cells.clear()
	_openings.clear()
	_origins.clear()
	if not FileAccess.file_exists(INDEX_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(INDEX_PATH))
	if not parsed is Dictionary:
		push_error("WorldMap: %s is not a JSON object." % INDEX_PATH)
		return
	var index: Dictionary = parsed
	for entry: Dictionary in index.get("rooms", []):
		var origin: Array = entry.get("origin", [0, 0])
		if not entry.get("secret", false):
			_origins[str(entry["id"])] = Vector2i(int(origin[0]), int(origin[1]))
		for pair: Array in entry.get("cells", []):
			cells[Vector2i(int(pair[0]), int(pair[1]))] = entry
	for opening: Array in index.get("openings", []):
		var a: Array = opening[0]
		var b: Array = opening[1]
		_openings[_edge_key(Vector2i(int(a[0]), int(a[1])), Vector2i(int(b[0]), int(b[1])))] = true


func _physics_process(_delta: float) -> void:
	var player: Node2D = get_tree().get_first_node_in_group(&"player") as Node2D
	var room: Node2D = get_tree().get_first_node_in_group(&"room") as Node2D
	# Test rooms kept off the map (on_map = false) discover nothing.
	if player == null or room == null or room.get(&"on_map") == false:
		return
	locate(room, room.to_local(player.global_position))


## Records that Elam stands at [param local] (room coordinates, feet) in [param room],
## and discovers that cell.
func locate(room: Node, local: Vector2) -> void:
	# Feet rest on a cell's bottom edge, so look a pixel up.
	var scaled: Vector2 = (local - Vector2(0, 1)) / CELL_SIZE
	player_cell = room_origin(room) + Vector2i(scaled.floor())
	player_offset = scaled - scaled.floor()
	has_player = true
	discover_cell(player_cell)


## The world map cell of the top-left of [param room]: from the index, or the room's own
## [code]map_cell[/code] if the index doesn't list it yet.
func room_origin(room: Node) -> Vector2i:
	var id: String = WorldKeys.room_id(room)
	if _origins.has(id):
		return _origins[id]
	var own: Variant = room.get(&"map_cell")
	return own if own is Vector2i else Vector2i.ZERO


## Marks [param cell] as discovered.
func discover_cell(cell: Vector2i) -> void:
	discovered[cell] = true


## Returns true if [param cell] has been discovered.
func is_discovered(cell: Vector2i) -> bool:
	return discovered.has(cell)


## True if a Surveyor's Map Elam owns shows [param cell] (MAP-005). Secret rooms never
## show until found.
func is_revealed(cell: Vector2i) -> bool:
	var entry: Dictionary = entry_at(cell)
	if entry.is_empty() or entry.get("secret", false):
		return false
	var region: StringName = StringName(str(entry.get("region", "")))
	for id: StringName in Game.inventory.ids():
		var map: MapData = Game.item(id) as MapData
		if map != null and map.covers(cell, region):
			return true
	return false


## The room entry of [param cell], or an empty dictionary if no room covers it.
func entry_at(cell: Vector2i) -> Dictionary:
	return cells.get(cell, {})


## True if a passage joins neighbouring cells [param a] and [param b].
func has_opening(a: Vector2i, b: Vector2i) -> bool:
	return _openings.has(_edge_key(a, b))


## Share of the map explored, in percent: discovered cells of ordinary rooms over all of
## them, plus the same share again for discovered secret cells (so secrets can take it
## past 100%, as in Symphony of the Night).
func explored_percent() -> float:
	var total: int = 0
	var found: int = 0
	for cell: Vector2i in cells:
		var secret: bool = cells[cell].get("secret", false)
		if not secret:
			total += 1
		if discovered.has(cell):
			found += 1
	return 100.0 * found / total if total > 0 else 0.0


## Forgets every discovered cell (a new game).
func reset() -> void:
	discovered.clear()
	has_player = false


## The discovered cells, for SaveSystem.
func save_data() -> Dictionary:
	var pairs: Array[Array] = []
	for cell: Vector2i in discovered:
		pairs.append([cell.x, cell.y])
	return {"discovered": pairs}


## Restores what [method save_data] returned (anything else starts unexplored).
func load_data(data: Dictionary) -> void:
	reset()
	for pair: Variant in data.get("discovered", []):
		if pair is Array and (pair as Array).size() == 2:
			discovered[Vector2i(int(pair[0]), int(pair[1]))] = true


static func _edge_key(a: Vector2i, b: Vector2i) -> String:
	var first: Vector2i = a if a < b else b
	var second: Vector2i = b if a < b else a
	return "%d,%d|%d,%d" % [first.x, first.y, second.x, second.y]
