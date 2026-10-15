extends GutTest
## WLD-006 breakable tiles: the greybox TileSet's breakable data, grouping of touching
## cells, hit counts, and that a broken group stays broken when the layer is rebuilt.

const Greybox := preload("res://tools/builders/build_greybox_tileset.gd")
const TILE_SET: TileSet = preload("res://assets/tilesets/greybox/greybox_tileset.tres")
const HIDDEN_PATCH: Array[Vector2i] = [Vector2i(5, 5), Vector2i(6, 5), Vector2i(5, 6), Vector2i(6, 6)]
const BRICK: Vector2i = Vector2i(10, 5)
const PLAIN: Vector2i = Vector2i(7, 5)


func before_each() -> void:
	Game.reset()


func after_all() -> void:
	Game.reset()


## A "Solid" layer with a 2×2 hidden patch, a plain solid tile touching it and a lone
## cracked brick, plus its BreakableTiles (scanned on the next frame).
func _layer() -> TileMapLayer:
	var layer: TileMapLayer = TileMapLayer.new()
	layer.name = "Solid"
	layer.tile_set = TILE_SET
	for cell: Vector2i in HIDDEN_PATCH:
		layer.set_cell(cell, 0, Greybox.SOLID, Greybox.HIDDEN_BREAKABLE_ALT)
	layer.set_cell(PLAIN, 0, Greybox.SOLID)
	layer.set_cell(BRICK, 0, Greybox.BREAKABLE)
	var breakables: BreakableTiles = BreakableTiles.new()
	layer.add_child(breakables)
	add_child_autofree(layer)
	return layer


func _breakables(layer: TileMapLayer) -> BreakableTiles:
	return layer.get_child(0) as BreakableTiles


func test_tileset_marks_what_breaks() -> void:
	var source: TileSetAtlasSource = TILE_SET.get_source(0) as TileSetAtlasSource
	assert_eq(source.get_tile_data(Greybox.SOLID, 0).get_custom_data("breakable"), 0, "plain solid")
	var hidden: TileData = source.get_tile_data(Greybox.SOLID, Greybox.HIDDEN_BREAKABLE_ALT)
	assert_eq(hidden.get_custom_data("breakable"), Greybox.HIDDEN_HITS, "hidden wall")
	assert_eq(hidden.get_collision_polygons_count(0), 1, "the hidden wall is solid until broken")
	assert_eq(source.get_tile_data(Greybox.BREAKABLE, 0).get_custom_data("breakable"), Greybox.BRICK_HITS)


func test_touching_cells_form_one_group() -> void:
	var layer: TileMapLayer = _layer()
	await wait_physics_frames(2)
	var breakables: BreakableTiles = _breakables(layer)
	assert_eq(breakables.group_count(), 2, "the hidden patch and the brick")
	assert_eq(breakables.hits_left(Vector2i(6, 6)), Greybox.HIDDEN_HITS)
	assert_eq(breakables.hits_left(BRICK), Greybox.BRICK_HITS)
	assert_eq(breakables.hits_left(PLAIN), 0, "plain solid is not breakable")


func test_the_last_hit_breaks_the_whole_group() -> void:
	var layer: TileMapLayer = _layer()
	await wait_physics_frames(2)
	var breakables: BreakableTiles = _breakables(layer)
	for i: int in Greybox.HIDDEN_HITS - 1:
		assert_true(breakables.strike(Vector2i(5, 5)))
	assert_eq(layer.get_cell_source_id(Vector2i(6, 6)), 0, "still standing after %d hits" % (Greybox.HIDDEN_HITS - 1))
	assert_eq(breakables.hits_left(Vector2i(6, 6)), 1)
	breakables.strike(Vector2i(5, 5))
	for cell: Vector2i in HIDDEN_PATCH:
		assert_eq(layer.get_cell_source_id(cell), -1, "%s broken" % cell)
	assert_eq(layer.get_cell_source_id(PLAIN), 0, "the plain tile beside it stays")
	assert_eq(layer.get_cell_source_id(BRICK), 0, "the brick is its own group")
	assert_eq(breakables.group_count(), 1)
	assert_false(breakables.strike(Vector2i(5, 5)), "nothing left to hit")


func test_broken_walls_stay_broken_on_reload() -> void:
	var layer: TileMapLayer = _layer()
	await wait_physics_frames(2)
	var breakables: BreakableTiles = _breakables(layer)
	for i: int in Greybox.BRICK_HITS:
		breakables.strike(BRICK)
	var flags: int = Game.flags.size()
	assert_eq(flags, 1, "one flag for the broken brick")
	layer.free()
	var again: TileMapLayer = _layer()
	await wait_physics_frames(2)
	assert_eq(again.get_cell_source_id(BRICK), -1, "the brick is gone when the room is rebuilt")
	assert_eq(again.get_cell_source_id(Vector2i(5, 5)), 0, "the unbroken patch is back")
	assert_eq(_breakables(again).group_count(), 1)


func test_flags_name_the_room_layer_and_corner() -> void:
	var layer: TileMapLayer = _layer()
	await wait_physics_frames(2)
	var breakables: BreakableTiles = _breakables(layer)
	for i: int in Greybox.HIDDEN_HITS:
		breakables.strike(Vector2i(6, 6))
	var flag: String = String(Game.flags.keys()[0])
	assert_string_ends_with(flag, "/Solid@5,5", "layer name and top-left cell")
