class_name SandboxRoom
extends Node2D
## Test room for the playable core, three screens wide, built in code from greybox tiles
## until rooms are authored (LVL-GTE-2). Left to right: 45° ramps over a plateau,
## stacked one-way platforms, a pillar to jump, the Gazelle Anklet on a ledge, a wall
## that needs the double jump, and every enemy type (Mudborn, Gate Spearman, and Humbaba
## Masks in the middle stretch).

const Greybox := preload("res://tools/builders/build_greybox_tileset.gd")
const TILE_SET: TileSet = preload("res://assets/tilesets/greybox/greybox_tileset.tres")
const MUDBORN: PackedScene = preload("res://scenes/actors/enemies/mudborn/mudborn.tscn")
const SPEARMAN: PackedScene = preload("res://scenes/actors/enemies/gate_spearman/gate_spearman.tscn")
const RELIC: PackedScene = preload("res://scenes/world/pickups/relic_pickup.tscn")
const TILE: int = 16
const WIDTH: int = 120
const HEIGHT: int = 23
const FLOOR_ROW: int = 20

## Where the player appears (feet), in room coordinates.
var spawn_point: Vector2 = Vector2(4 * TILE, FLOOR_ROW * TILE)
## Camera limits for this room.
var bounds: Rect2 = Rect2(0, 0, WIDTH * TILE, 360)

var _back: TileMapLayer
var _solid: TileMapLayer
var _platforms: TileMapLayer
var _entities: Node2D


func _ready() -> void:
	_back = _add_layer("BackWall", -5)
	_solid = _add_layer("Solid", 0)
	_platforms = _add_layer("Platforms", 0)
	_entities = Node2D.new()
	_entities.name = "Entities"
	add_child(_entities)
	_build_tiles()
	_spawn_entities()


func _build_tiles() -> void:
	_fill(_back, Rect2i(0, 0, WIDTH, HEIGHT), Greybox.BACK_WALL)
	_fill(_solid, Rect2i(0, FLOOR_ROW, WIDTH, HEIGHT - FLOOR_ROW), Greybox.SOLID)
	_fill(_solid, Rect2i(0, 0, 2, FLOOR_ROW), Greybox.SOLID)
	_fill(_solid, Rect2i(WIDTH - 2, 0, 2, FLOOR_ROW), Greybox.SOLID)
	# Ramp up (10-13), plateau (14-21), ramp down (22-25).
	for i: int in 4:
		var up: Vector2i = Vector2i(10 + i, FLOOR_ROW - 1 - i)
		var down: Vector2i = Vector2i(22 + i, 16 + i)
		_solid.set_cell(up, 0, Greybox.SLOPE_UP_RIGHT)
		_solid.set_cell(down, 0, Greybox.SLOPE_UP_LEFT)
		_fill(_solid, Rect2i(up.x, up.y + 1, 1, FLOOR_ROW - up.y - 1), Greybox.SOLID)
		_fill(_solid, Rect2i(down.x, down.y + 1, 1, FLOOR_ROW - down.y - 1), Greybox.SOLID)
	_fill(_solid, Rect2i(14, 16, 8, 4), Greybox.SOLID)
	# Stacked one-way platforms.
	_fill(_platforms, Rect2i(29, 15, 6, 1), Greybox.PLATFORM)
	_fill(_platforms, Rect2i(35, 11, 6, 1), Greybox.PLATFORM)
	_fill(_platforms, Rect2i(29, 7, 5, 1), Greybox.PLATFORM)
	# Pillar (6 tiles: a normal jump clears it).
	_fill(_solid, Rect2i(47, 14, 2, 6), Greybox.SOLID)
	# Relic ledge (6 tiles high).
	_fill(_solid, Rect2i(72, 14, 8, 6), Greybox.SOLID)
	# Wall of 10 tiles (160 px): needs the double jump (144 + 96 px).
	_fill(_solid, Rect2i(92, 10, 2, 10), Greybox.SOLID)


func _spawn_entities() -> void:
	_spawn(MUDBORN, Vector2i(18, 16), -1)
	_spawn(MUDBORN, Vector2i(42, FLOOR_ROW), -1)
	_spawn(SPEARMAN, Vector2i(58, FLOOR_ROW), -1)
	_spawn(SPEARMAN, Vector2i(104, FLOOR_ROW), -1)
	_spawn(MUDBORN, Vector2i(111, FLOOR_ROW), -1)
	var relic: Node2D = RELIC.instantiate() as Node2D
	relic.position = Vector2(76 * TILE, 14 * TILE)
	_entities.add_child(relic)
	var spawner: MaskSpawner = MaskSpawner.new()
	spawner.zone = Vector2(60 * TILE, 90 * TILE)
	spawner.height_band = Vector2(10 * TILE, 14 * TILE)
	_entities.add_child(spawner)


func _spawn(scene: PackedScene, cell: Vector2i, facing: int) -> void:
	var enemy: Enemy = scene.instantiate() as Enemy
	enemy.position = Vector2(cell.x * TILE + TILE / 2.0, cell.y * TILE)
	enemy.facing = facing
	_entities.add_child(enemy)


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
