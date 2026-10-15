class_name SandboxRoom
extends Node2D
## Test room for the playable core, three screens wide, built in code from greybox tiles
## until rooms are authored (LVL-GTE-2). Left to right: 45° ramps over a plateau,
## stacked one-way platforms, a pillar to jump, the Gazelle Anklet on a ledge, a wall
## that needs the double jump, and every enemy type (Mudborn, Gate Spearman, and Humbaba
## Masks in the middle stretch). Secrets (WLD-006): a cracked-brick block in the middle
## stretch, a hidden floor past the double-jump wall over a cellar, and a hidden stretch
## of the far right wall into a secret room. Both secret rooms lie outside the camera
## bounds, so they stay out of sight until Elam gets in.

const Greybox := preload("res://tools/builders/build_greybox_tileset.gd")
const TILE_SET: TileSet = preload("res://assets/tilesets/greybox/greybox_tileset.tres")
const MUDBORN: PackedScene = preload("res://scenes/actors/enemies/mudborn/mudborn.tscn")
const SPEARMAN: PackedScene = preload("res://scenes/actors/enemies/gate_spearman/gate_spearman.tscn")
const RELIC: PackedScene = preload("res://scenes/world/pickups/relic_pickup.tscn")
const LAMP: PackedScene = preload("res://scenes/world/props/votive_lamp.tscn")
const ALTAR: PackedScene = preload("res://scenes/world/props/save_altar.tscn")
## Votive lamp positions (tile x, tile y of the floor they stand on).
const LAMPS: Array[Vector2i] = [
	Vector2i(9, 20), Vector2i(17, 16), Vector2i(31, 15), Vector2i(38, 11),
	Vector2i(52, 20), Vector2i(66, 20), Vector2i(86, 20), Vector2i(108, 20),
]
## Hidden wall (east secret room), hidden floor (cellar) and the cracked block, in tiles.
const HIDDEN_WALL: Rect2i = Rect2i(118, 14, 2, 6)
const HIDDEN_FLOOR: Rect2i = Rect2i(98, 20, 3, 3)
const CRACKED_BLOCK: Rect2i = Rect2i(64, 17, 2, 3)
## Secret rooms beyond the bounds: interiors in tiles.
const EAST_ROOM: Rect2i = Rect2i(120, 10, 14, 10)
const CELLAR: Rect2i = Rect2i(96, 23, 9, 7)
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
	add_to_group(&"room")
	_back = _add_layer("BackWall", -5)
	_solid = _add_layer("Solid", 0)
	_platforms = _add_layer("Platforms", 0)
	_entities = Node2D.new()
	_entities.name = "Entities"
	add_child(_entities)
	_build_tiles()
	_build_secrets()
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


## The breakable tiles and the two secret rooms behind them (WLD-006).
func _build_secrets() -> void:
	_fill(_solid, HIDDEN_WALL, Greybox.SOLID, Greybox.HIDDEN_BREAKABLE_ALT)
	_fill(_solid, HIDDEN_FLOOR, Greybox.SOLID, Greybox.HIDDEN_BREAKABLE_ALT)
	_fill(_solid, CRACKED_BLOCK, Greybox.BREAKABLE)
	# East room: thick ceiling, floor and far wall around the interior.
	var east: Rect2i = EAST_ROOM.grow_individual(0, EAST_ROOM.position.y, 2, HEIGHT - EAST_ROOM.end.y)
	_fill(_back, east, Greybox.BACK_WALL)
	_fill(_solid, Rect2i(east.position.x, 0, east.size.x, EAST_ROOM.position.y), Greybox.SOLID)
	_fill(_solid, Rect2i(east.position.x, FLOOR_ROW, east.size.x, HEIGHT - FLOOR_ROW), Greybox.SOLID)
	_fill(_solid, Rect2i(EAST_ROOM.end.x, EAST_ROOM.position.y, 2, EAST_ROOM.size.y), Greybox.SOLID)
	# Cellar dug into the rock under the floor (rock wherever its camera view can reach),
	# with a ledge to climb back out through the hole.
	_fill(_back, CELLAR, Greybox.BACK_WALL)
	var rock: Rect2i = Rect2i(80, HEIGHT, WIDTH - 80, CELLAR.end.y + 2 - HEIGHT)
	for y: int in range(rock.position.y, rock.end.y):
		for x: int in range(rock.position.x, rock.end.x):
			if not CELLAR.has_point(Vector2i(x, y)):
				_solid.set_cell(Vector2i(x, y), 0, Greybox.SOLID)
	_fill(_platforms, Rect2i(HIDDEN_FLOOR.position.x - 1, CELLAR.position.y + 3, HIDDEN_FLOOR.size.x + 2, 1),
			Greybox.PLATFORM)
	var breakables: BreakableTiles = BreakableTiles.new()
	breakables.name = "Breakables"
	_solid.add_child(breakables)
	_add_secret("EastRoom", EAST_ROOM, Rect2(Vector2(EAST_ROOM.end.x + 2, 0) * TILE - Vector2(640, 0), Vector2(640, 360)))
	_add_secret("Cellar", CELLAR, Rect2(Vector2(80 * TILE, (CELLAR.end.y + 2) * TILE - 360), Vector2(640, 360)))


func _add_secret(secret_name: String, interior: Rect2i, view: Rect2) -> void:
	var secret: SecretArea = SecretArea.new()
	secret.name = secret_name
	secret.area = Rect2(Vector2(interior.position) * TILE, Vector2(interior.size) * TILE)
	secret.view = view
	add_child(secret)


func _spawn_entities() -> void:
	_spawn(MUDBORN, Vector2i(18, 16), -1)
	_spawn(MUDBORN, Vector2i(42, FLOOR_ROW), -1)
	_spawn(SPEARMAN, Vector2i(58, FLOOR_ROW), -1)
	_spawn(SPEARMAN, Vector2i(104, FLOOR_ROW), -1)
	_spawn(MUDBORN, Vector2i(111, FLOOR_ROW), -1)
	var relic: Node2D = RELIC.instantiate() as Node2D
	relic.position = Vector2(76 * TILE, 14 * TILE)
	_entities.add_child(relic)
	for cell: Vector2i in LAMPS:
		var lamp: Node2D = LAMP.instantiate() as Node2D
		lamp.position = Vector2(cell.x * TILE + TILE / 2.0, cell.y * TILE)
		_entities.add_child(lamp)
	# Rewards in the secret rooms.
	for cell: Vector2i in [Vector2i(123, FLOOR_ROW), Vector2i(127, FLOOR_ROW), Vector2i(131, FLOOR_ROW),
			Vector2i(97, CELLAR.end.y), Vector2i(103, CELLAR.end.y)]:
		var lamp: Node2D = LAMP.instantiate() as Node2D
		lamp.position = Vector2(cell.x * TILE + TILE / 2.0, cell.y * TILE)
		_entities.add_child(lamp)
	var altar: Node2D = ALTAR.instantiate() as Node2D
	altar.position = Vector2(6 * TILE, FLOOR_ROW * TILE)
	_entities.add_child(altar)
	var spawner: MaskSpawner = MaskSpawner.new()
	spawner.zone = Vector2(60 * TILE, 90 * TILE)
	spawner.height_band = Vector2(10 * TILE, 14 * TILE)
	_entities.add_child(spawner)


func _spawn(scene: PackedScene, cell: Vector2i, facing: int) -> void:
	var enemy: Enemy = scene.instantiate() as Enemy
	enemy.position = Vector2(cell.x * TILE + TILE / 2.0, cell.y * TILE)
	enemy.facing = facing
	_entities.add_child(enemy)


func _fill(layer: TileMapLayer, rect: Rect2i, tile: Vector2i, alternative: int = 0) -> void:
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			layer.set_cell(Vector2i(x, y), 0, tile, alternative)


func _add_layer(layer_name: String, z: int) -> TileMapLayer:
	var layer: TileMapLayer = TileMapLayer.new()
	layer.name = layer_name
	layer.tile_set = TILE_SET
	layer.z_index = z
	add_child(layer)
	return layer
