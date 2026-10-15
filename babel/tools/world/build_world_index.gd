extends SceneTree
## MAP-001: builds data/world_index.json, the map's picture of the world. Instantiates
## every room scene under scenes/world/rooms/ and records:
##   - each room's map cells (one screen, 640×360 px), placed by its `map_cell` and
##     sized by its `bounds`, with its `region` for the map's colours;
##   - each SecretArea (WLD-006) as its own hidden room, over the cells it covers outside
##     the room's bounds;
##   - the openings between neighbouring cells, read from the room's "Solid" tiles: a
##     shared edge is open where at least MIN_OPENING tile rows (or columns) are free on
##     both sides. Breakable tiles count as free (they are passages once broken).
## It refers to SecretArea and BreakableTiles only by name: a -s script is compiled before
## the autoloads exist, and those classes use Game.
## Run it after changing a room:
##   godot --headless --path babel -s res://tools/world/build_world_index.gd

const ROOMS_DIR: String = "res://scenes/world/rooms"
const OUT: String = "res://data/world_index.json"
const CELL: Vector2 = Vector2(640, 360)
const MIN_OPENING: int = 2
## Tile custom data marking breakable tiles (BreakableTiles.CUSTOM_DATA).
const BREAKABLE: String = "breakable"

var _rooms: Array[Dictionary] = []
var _openings: Array[Array] = []


func _initialize() -> void:
	# Rooms only run _ready() once the tree is up, on the first frame.
	process_frame.connect(_build, CONNECT_ONE_SHOT)


func _build() -> void:
	for path: String in FileScan.list_files(ROOMS_DIR, [".tscn"]):
		var room: Node = (load(path) as PackedScene).instantiate()
		root.add_child(room)
		if room.get(&"bounds") is Rect2:
			_describe(room, path)
		else:
			print("world_index: skipped %s (no bounds)" % path)
		root.remove_child(room)
		room.free()
	var index: Dictionary = {
		"version": 1,
		"cell_size": [int(CELL.x), int(CELL.y)],
		"rooms": _rooms,
		"openings": _openings,
	}
	var file: FileAccess = FileAccess.open(OUT, FileAccess.WRITE)
	file.store_string(JSON.stringify(index, "\t", false) + "\n")
	file.close()
	var cells: int = 0
	for entry: Dictionary in _rooms:
		cells += (entry["cells"] as Array).size()
	print("world_index: wrote %s (%d rooms, %d cells, %d openings)" % [OUT, _rooms.size(), cells, _openings.size()])
	quit()


## Adds [param room] and its secret areas to the index.
func _describe(room: Node, path: String) -> void:
	var origin: Vector2i = room.get(&"map_cell") if room.get(&"map_cell") is Vector2i else Vector2i.ZERO
	var region: String = String(room.get(&"region")) if room.get(&"region") != null else "none"
	var bounds: Rect2 = room.get(&"bounds")
	var own: Array[Vector2i] = _cells(bounds, origin)
	var by_cell: Dictionary[Vector2i, String] = {}
	var id: String = WorldKeys.room_id(room)
	_add_entry(id, path, region, false, origin, own, by_cell)
	for secret: Node in room.get_tree().get_nodes_in_group(&"secret_area"):
		if not room.is_ancestor_of(secret):
			continue
		var global_area: Rect2 = secret.call(&"global_area")
		var area: Rect2 = Rect2((room as Node2D).to_local(global_area.position), global_area.size)
		var cells: Array[Vector2i] = []
		for cell: Vector2i in _cells(area, origin):
			if not by_cell.has(cell):
				cells.append(cell)
		_add_entry(String(secret.call(&"flag")), path, region, true, origin, cells, by_cell)
	var solid: TileMapLayer = room.get_node_or_null(^"Solid") as TileMapLayer
	if solid == null:
		return
	for cell: Vector2i in by_cell:
		for step: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN]:
			var next: Vector2i = cell + step
			if by_cell.has(next) and by_cell[next] != by_cell[cell] and _is_open(solid, cell - origin, step):
				_openings.append([[cell.x, cell.y], [next.x, next.y]])


func _add_entry(id: String, path: String, region: String, secret: bool, origin: Vector2i, cells: Array[Vector2i],
		by_cell: Dictionary[Vector2i, String]) -> void:
	var pairs: Array[Array] = []
	for cell: Vector2i in cells:
		pairs.append([cell.x, cell.y])
		by_cell[cell] = id
	_rooms.append({
		"id": id, "scene": path, "region": region, "secret": secret,
		"origin": [origin.x, origin.y], "cells": pairs,
	})


## Map cells covered by [param rect] (room coordinates), offset by [param origin].
func _cells(rect: Rect2, origin: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y: int in range(floori(rect.position.y / CELL.y), ceili(rect.end.y / CELL.y)):
		for x: int in range(floori(rect.position.x / CELL.x), ceili(rect.end.x / CELL.x)):
			cells.append(origin + Vector2i(x, y))
	return cells


## True if the edge between room-local map cell [param cell] and its neighbour in
## direction [param step] (right or down) has a passage through the Solid tiles.
func _is_open(solid: TileMapLayer, cell: Vector2i, step: Vector2i) -> bool:
	var tile: Vector2 = Vector2(solid.tile_set.tile_size)
	var free: int = 0
	if step == Vector2i.RIGHT:
		var x: float = (cell.x + 1) * CELL.x
		var before: int = floori((x - 1.0) / tile.x)
		var after: int = floori(x / tile.x)
		for row: int in range(floori(cell.y * CELL.y / tile.y), floori(((cell.y + 1) * CELL.y - 1.0) / tile.y) + 1):
			free = free + 1 if _passable(solid, Vector2i(before, row)) and _passable(solid, Vector2i(after, row)) else 0
			if free >= MIN_OPENING:
				return true
	else:
		var y: float = (cell.y + 1) * CELL.y
		var above: int = floori((y - 1.0) / tile.y)
		var below: int = floori(y / tile.y)
		for column: int in range(floori(cell.x * CELL.x / tile.x), floori(((cell.x + 1) * CELL.x - 1.0) / tile.x) + 1):
			free = free + 1 if _passable(solid, Vector2i(column, above)) and _passable(solid, Vector2i(column, below)) else 0
			if free >= MIN_OPENING:
				return true
	return false


func _passable(solid: TileMapLayer, tile: Vector2i) -> bool:
	var data: TileData = solid.get_cell_tile_data(tile)
	if data == null:
		return true
	return solid.tile_set.has_custom_data_layer_by_name(BREAKABLE) and int(data.get_custom_data(BREAKABLE)) > 0
