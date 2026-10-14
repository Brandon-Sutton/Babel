extends Node2D
## PIPE-006: paints a room with an imported PixelLab tileset through the terrain API
## (set_cells_terrain_connect, like the editor's terrain brush), then walks the
## placeholder capsule across it. Logs "VISUAL PASS"/"VISUAL FAIL": every painted cell
## must have received a tile, and the capsule must land on the floor and stop at the wall.
##
## PixelLab sidescroller tiles are corner-based, so a painted area's solid edge (art and
## collision alike) sits half a tile INSIDE the painted cells: painting rows 19+ puts the
## floor surface at y = 19 * 16 + 8. The checks below assert exactly that; WLD-023 adds a
## dual-grid art layer that lines the art up with the 16 px logic grid instead.
## Needs a real window: run it via tools/capture.sh.

const Capsule := preload("res://tests/visual/greybox_room.gd").Capsule
const WALK_FRAMES: int = 420
const FLOOR_ROW: int = 19
const WALL_COLUMN: int = 30

@export var tile_set: TileSet = preload("res://assets/tilesets/gte/gte_solid.tres")

var _layer: TileMapLayer
var _painted: Array[Vector2i] = []
var _capsule: CharacterBody2D
var _frame: int = 0


func _ready() -> void:
	_layer = TileMapLayer.new()
	_layer.tile_set = tile_set
	add_child(_layer)
	_paint_rect(Rect2i(0, FLOOR_ROW, 40, 4))   # floor
	_paint_rect(Rect2i(WALL_COLUMN, 13, 10, 6))  # wall the capsule walks into
	_paint_rect(Rect2i(10, 8, 8, 3))           # floating block (shows every edge tile)
	_paint_rect(Rect2i(22, 4, 2, 6))           # hanging pillar
	_layer.set_cells_terrain_connect(_painted, 0, 0)

	_capsule = Capsule.new()
	_capsule.position = Vector2(2 * 16, 15 * 16)
	add_child(_capsule)


func _physics_process(_delta: float) -> void:
	_frame += 1
	if _frame == WALK_FRAMES:
		_verify()


func _paint_rect(rect: Rect2i) -> void:
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			_painted.append(Vector2i(x, y))


func _verify() -> void:
	var holes: int = 0
	for cell: Vector2i in _painted:
		if _layer.get_cell_source_id(cell) == -1:
			holes += 1
	var floor_surface: float = (_capsule as Capsule).highest_floor_y + Capsule.HEIGHT / 2.0
	var wall_x: float = _capsule.position.x + Capsule.RADIUS
	var grounded: bool = _capsule.is_on_floor()
	# Corner tiles: solid edges sit half a tile (8 px) inside the painted cells.
	var floor_ok: bool = absf(floor_surface - (FLOOR_ROW * 16 + 8)) <= 1.0
	var wall_ok: bool = absf(wall_x - (WALL_COLUMN * 16 + 8)) <= 1.0
	var result: String = "PASS" if holes == 0 and grounded and floor_ok and wall_ok else "FAIL"
	print("VISUAL %s tileset_room: %d holes in %d painted cells, floor surface y=%.1f, wall contact x=%.1f, on_floor=%s" % [
		result, holes, _painted.size(), floor_surface, wall_x, grounded])
