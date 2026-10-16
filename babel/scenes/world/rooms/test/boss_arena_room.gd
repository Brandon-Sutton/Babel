extends Node2D
## Test room for the boss framework (BOSS-000, BOSS-030): a corridor with two lamps,
## then a gate into a one-screen arena where the Weeping Effigy waits. Stepping into the
## arena drops the gate behind Elam and starts the fight. Reached with the debug warp
## (F6) until rooms connect (WLD-002); kept off the world map.

const Greybox := preload("res://tools/builders/build_greybox_tileset.gd")
const TILE_SET: TileSet = preload("res://assets/tilesets/greybox/greybox_tileset.tres")
const EFFIGY: PackedScene = preload("res://scenes/actors/bosses/test_effigy/test_effigy.tscn")
const LAMP: PackedScene = preload("res://scenes/world/props/votive_lamp.tscn")
const TILE: int = 16
const WIDTH: int = 60
const HEIGHT: int = 23
const FLOOR_ROW: int = 20
## The arena starts at this tile column; the gate stands just before it.
const ARENA_COLUMN: int = 20
const GATE_TOP_ROW: int = 12
const EFFIGY_COLUMN: int = 46

## Where the player appears (feet), in room coordinates.
var spawn_point: Vector2 = Vector2(4 * TILE, FLOOR_ROW * TILE)
## Camera limits for this room.
var bounds: Rect2 = Rect2(0, 0, WIDTH * TILE, 360)
var map_cell: Vector2i = Vector2i.ZERO
var region: StringName = &"test"
## A test room: no map cells and no discovery (WorldMap, MAP-001).
var on_map: bool = false

var _solid: TileMapLayer


func _ready() -> void:
	add_to_group(&"room")
	var back: TileMapLayer = _add_layer("BackWall", -5)
	_solid = _add_layer("Solid", 0)
	_fill(back, Rect2i(0, 0, WIDTH, HEIGHT), Greybox.BACK_WALL)
	_fill(_solid, Rect2i(0, FLOOR_ROW, WIDTH, HEIGHT - FLOOR_ROW), Greybox.SOLID)
	_fill(_solid, Rect2i(0, 0, 2, FLOOR_ROW), Greybox.SOLID)
	_fill(_solid, Rect2i(WIDTH - 2, 0, 2, FLOOR_ROW), Greybox.SOLID)
	# The gateway: a wall above the gate opening.
	_fill(_solid, Rect2i(ARENA_COLUMN - 1, 0, 1, GATE_TOP_ROW), Greybox.SOLID)
	var entities: Node2D = Node2D.new()
	entities.name = "Entities"
	add_child(entities)
	for column: int in [6, 12]:
		var lamp: Node2D = LAMP.instantiate() as Node2D
		lamp.position = Vector2(column * TILE + TILE / 2.0, FLOOR_ROW * TILE)
		entities.add_child(lamp)
	var effigy: Boss = EFFIGY.instantiate() as Boss
	effigy.name = "Effigy"
	effigy.position = Vector2(EFFIGY_COLUMN * TILE, FLOOR_ROW * TILE)
	effigy.facing = -1
	entities.add_child(effigy)
	var arena: BossArena = BossArena.new()
	arena.name = "Arena"
	arena.boss = effigy
	arena.area = Rect2(ARENA_COLUMN * TILE, 0, 640, 360)
	arena.trigger = Rect2(ARENA_COLUMN * TILE + 48, 0, 640 - 48, 360)
	arena.gates = [Rect2((ARENA_COLUMN - 1) * TILE, GATE_TOP_ROW * TILE, TILE, (FLOOR_ROW - GATE_TOP_ROW) * TILE)]
	add_child(arena)


func _fill(layer: TileMapLayer, rect: Rect2i, tile: Vector2i) -> void:
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			layer.set_cell(Vector2i(x, y), 0, tile)


func _add_layer(layer_name: String, z: int) -> TileMapLayer:
	var layer: TileMapLayer = TileMapLayer.new()
	layer.name = layer_name
	layer.tile_set = TILE_SET
	layer.z_index = z
	add_child(layer)
	return layer
