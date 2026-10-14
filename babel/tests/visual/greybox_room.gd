extends Node2D
## LVL-002 / M0: greybox test room. Paints a one-screen room with every greybox tile
## (floor, 45° ramps, plateau, spikes, one-way platform, water, breakable wall, back
## wall) and drops in a placeholder capsule that walks right. After WALK_FRAMES it logs
## "VISUAL PASS"/"VISUAL FAIL": the capsule must have climbed onto the plateau, crossed
## the spikes and stopped standing against the breakable wall.
## Needs a real window: run it via tools/capture.sh.

const Greybox := preload("res://tools/builders/build_greybox_tileset.gd")
const TILE_SET: TileSet = preload("res://assets/tilesets/greybox/greybox_tileset.tres")
const ROOM_TILES: Vector2i = Vector2i(40, 23)
const FLOOR_ROW: int = 20
const PLATEAU_ROW: int = 16
const WALL_COLUMN: int = 38
const WALK_FRAMES: int = 480

var _frame: int = 0
var _capsule: Capsule


## Placeholder player: a walking capsule with gravity, on the player collision layer.
class Capsule extends CharacterBody2D:
	const SPEED: float = 90.0
	const GRAVITY: float = 1590.0
	const RADIUS: float = 6.0
	const HEIGHT: float = 32.0

	## Highest point (smallest y) reached while standing on something.
	var highest_floor_y: float = INF

	func _init() -> void:
		collision_layer = 1 << 2
		collision_mask = (1 << 0) | (1 << 1)
		floor_max_angle = deg_to_rad(46.0)
		floor_snap_length = 8.0
		var shape: CapsuleShape2D = CapsuleShape2D.new()
		shape.radius = RADIUS
		shape.height = HEIGHT
		var collision: CollisionShape2D = CollisionShape2D.new()
		collision.shape = shape
		add_child(collision)

	func _physics_process(delta: float) -> void:
		velocity.x = SPEED
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		move_and_slide()
		if is_on_floor():
			highest_floor_y = minf(highest_floor_y, position.y)

	func _draw() -> void:
		draw_rect(Rect2(-RADIUS, -HEIGHT / 2.0, RADIUS * 2.0, HEIGHT), Color("e8dfc4"))
		draw_rect(Rect2(-RADIUS, -HEIGHT / 2.0, RADIUS * 2.0, HEIGHT), Color("0b0a10"), false, 1.0)


func _ready() -> void:
	var back_wall: TileMapLayer = _add_layer("BackWall", -5)
	var solid: TileMapLayer = _add_layer("Solid", 0)
	var platforms: TileMapLayer = _add_layer("Platforms", 0)
	var fg: TileMapLayer = _add_layer("FgDeco", 50)

	for y: int in ROOM_TILES.y:
		for x: int in ROOM_TILES.x:
			back_wall.set_cell(Vector2i(x, y), 0, Greybox.BACK_WALL)
	# Floor with a spike strip.
	for x: int in ROOM_TILES.x:
		for y: int in range(FLOOR_ROW, ROOM_TILES.y):
			solid.set_cell(Vector2i(x, y), 0, Greybox.HAZARD if (y == FLOOR_ROW and x >= 24 and x <= 27) else Greybox.SOLID)
	# Ramp up (columns 8-11) to a plateau (12-17), ramp down (18-21).
	for i: int in 4:
		var up: Vector2i = Vector2i(8 + i, FLOOR_ROW - 1 - i)
		solid.set_cell(up, 0, Greybox.SLOPE_UP_RIGHT)
		var down: Vector2i = Vector2i(18 + i, PLATEAU_ROW + i)
		solid.set_cell(down, 0, Greybox.SLOPE_UP_LEFT)
		for y: int in range(up.y + 1, FLOOR_ROW):
			solid.set_cell(Vector2i(up.x, y), 0, Greybox.SOLID)
		for y: int in range(down.y + 1, FLOOR_ROW):
			solid.set_cell(Vector2i(down.x, y), 0, Greybox.SOLID)
	for x: int in range(12, 18):
		for y: int in range(PLATEAU_ROW, FLOOR_ROW):
			solid.set_cell(Vector2i(x, y), 0, Greybox.SOLID)
	# One-way platform overhead, a pool of (decorative) water, a breakable wall.
	for x: int in range(28, 34):
		platforms.set_cell(Vector2i(x, 13), 0, Greybox.PLATFORM)
	for x: int in range(30, 34):
		for y: int in range(FLOOR_ROW - 2, FLOOR_ROW):
			fg.set_cell(Vector2i(x, y), 0, Greybox.WATER)
	for x: int in range(WALL_COLUMN, ROOM_TILES.x):
		for y: int in range(FLOOR_ROW - 3, FLOOR_ROW):
			solid.set_cell(Vector2i(x, y), 0, Greybox.BREAKABLE)

	_capsule = Capsule.new()
	_capsule.position = Vector2(2 * 16, FLOOR_ROW * 16 - Capsule.HEIGHT / 2.0)
	add_child(_capsule)


func _physics_process(_delta: float) -> void:
	_frame += 1
	if _frame == WALK_FRAMES:
		_verify()


func _verify() -> void:
	var expected_plateau_y: float = PLATEAU_ROW * 16 - Capsule.HEIGHT / 2.0
	var expected_stop_x: float = WALL_COLUMN * 16 - Capsule.RADIUS
	var climbed: bool = absf(_capsule.highest_floor_y - expected_plateau_y) <= 2.0
	var stopped: bool = absf(_capsule.position.x - expected_stop_x) <= 2.0
	var grounded: bool = _capsule.is_on_floor()
	var result: String = "PASS" if climbed and stopped and grounded else "FAIL"
	print("VISUAL %s greybox: plateau y=%.1f (want %.1f), stop x=%.1f (want %.1f), on_floor=%s" % [
		result, _capsule.highest_floor_y, expected_plateau_y, _capsule.position.x, expected_stop_x, grounded])


func _add_layer(layer_name: String, z: int) -> TileMapLayer:
	var layer: TileMapLayer = TileMapLayer.new()
	layer.name = layer_name
	layer.tile_set = TILE_SET
	layer.z_index = z
	add_child(layer)
	return layer
