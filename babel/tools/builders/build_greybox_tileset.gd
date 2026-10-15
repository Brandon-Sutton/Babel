extends SceneTree
## LVL-002: builds the greybox TileSet used to block out rooms before final art exists.
## Writes the 16 px atlas PNG and greybox_tileset.tres in assets/tilesets/greybox/.
##
## Usage, from the repo root (the TileSet needs the PNG imported, so the first run may
## ask for an import and a second run):
##   godot --headless --path babel -s res://tools/builders/build_greybox_tileset.gd
##   godot --headless --path babel --import
##   godot --headless --path babel -s res://tools/builders/build_greybox_tileset.gd

const TILE: int = 16
const DIR: String = "res://assets/tilesets/greybox"
const PNG_PATH: String = DIR + "/greybox.png"
const TILESET_PATH: String = DIR + "/greybox_tileset.tres"

## Atlas coordinates of each greybox tile (source id 0, single row).
const SOLID: Vector2i = Vector2i(0, 0)
const PLATFORM: Vector2i = Vector2i(1, 0)
const SLOPE_UP_RIGHT: Vector2i = Vector2i(2, 0)
const SLOPE_UP_LEFT: Vector2i = Vector2i(3, 0)
const HAZARD: Vector2i = Vector2i(4, 0)
const BREAKABLE: Vector2i = Vector2i(5, 0)
const WATER: Vector2i = Vector2i(6, 0)
const BACK_WALL: Vector2i = Vector2i(7, 0)
const TILE_COUNT: int = 8
## Alternative of SOLID that looks the same but breaks (WLD-006): a hidden wall or floor.
const HIDDEN_BREAKABLE_ALT: int = 1
## Hits to break (custom data "breakable"): the hidden variant and the cracked brick.
const HIDDEN_HITS: int = 3
const BRICK_HITS: int = 2

## TileSet physics layer indices and the project collision layers (CLAUDE.md) they use.
const PHYS_WORLD: int = 0      # layer 1 "world"
const PHYS_PLATFORM: int = 1   # layer 2 "platform"
const PHYS_HAZARD: int = 2     # layer 14 "hazard"

# Collision polygons in tile-local coordinates (origin at the tile centre).
const POLY_FULL: PackedVector2Array = [Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)]
const POLY_PLATFORM: PackedVector2Array = [Vector2(-8, -8), Vector2(8, -8), Vector2(8, -2), Vector2(-8, -2)]
const POLY_SLOPE_UP_RIGHT: PackedVector2Array = [Vector2(-8, 8), Vector2(8, -8), Vector2(8, 8)]
const POLY_SLOPE_UP_LEFT: PackedVector2Array = [Vector2(-8, -8), Vector2(8, 8), Vector2(-8, 8)]

# Greybox colours (ART_BIBLE master ramps).
const C_FILL: Color = Color("3a3047")
const C_LIGHT: Color = Color("4b3d6e")
const C_DARK: Color = Color("241e2e")
const C_DEEP: Color = Color("17141f")
const C_PLATFORM: Color = Color("8b7fb8")
const C_SPIKE: Color = Color("c0263c")
const C_SPIKE_BASE: Color = Color("3d0a14")
const C_BRICK: Color = Color("7c3524")
const C_CRACK: Color = Color("4a1f17")
const C_WATER: Color = Color(0.173, 0.290, 0.604, 0.55)
const C_WATER_TOP: Color = Color(0.612, 0.765, 0.941, 0.8)


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR))
	if _write_png_if_changed(_draw_atlas()) or not FileAccess.file_exists(PNG_PATH + ".import"):
		print("greybox: atlas written to %s. Run --import, then run this builder again." % PNG_PATH)
		quit()
		return
	var texture: Texture2D = load(PNG_PATH)
	var err: Error = ResourceSaver.save(_build_tile_set(texture), TILESET_PATH)
	if err != OK:
		push_error("greybox: saving %s failed: %s" % [TILESET_PATH, error_string(err)])
		quit(1)
		return
	print("greybox: wrote %s (%d tiles)." % [TILESET_PATH, TILE_COUNT])
	quit()


## Returns true if the PNG on disk was missing or different and has been rewritten.
func _write_png_if_changed(image: Image) -> bool:
	var bytes: PackedByteArray = image.save_png_to_buffer()
	if FileAccess.file_exists(PNG_PATH) and FileAccess.get_file_as_bytes(PNG_PATH) == bytes:
		return false
	var file: FileAccess = FileAccess.open(PNG_PATH, FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()
	return true


func _build_tile_set(texture: Texture2D) -> TileSet:
	var tile_set: TileSet = TileSet.new()
	tile_set.tile_size = Vector2i(TILE, TILE)
	for collision_layer: int in [1 << 0, 1 << 1, 1 << 13]:
		var index: int = tile_set.get_physics_layers_count()
		tile_set.add_physics_layer()
		tile_set.set_physics_layer_collision_layer(index, collision_layer)
		tile_set.set_physics_layer_collision_mask(index, 0)
	tile_set.add_custom_data_layer()
	tile_set.set_custom_data_layer_name(0, "kind")
	tile_set.set_custom_data_layer_type(0, TYPE_STRING_NAME)
	# Hits needed to break the tile (0 = unbreakable), read by BreakableTiles (WLD-006).
	tile_set.add_custom_data_layer()
	tile_set.set_custom_data_layer_name(1, "breakable")
	tile_set.set_custom_data_layer_type(1, TYPE_INT)
	tile_set.add_terrain_set()
	tile_set.set_terrain_set_mode(0, TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES)
	tile_set.add_terrain(0)
	tile_set.set_terrain_name(0, 0, "solid")
	tile_set.set_terrain_color(0, 0, C_LIGHT)

	var source: TileSetAtlasSource = TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(TILE, TILE)
	tile_set.add_source(source, 0)
	for x: int in TILE_COUNT:
		source.create_tile(Vector2i(x, 0))

	_set_kind(source, SOLID, &"solid", PHYS_WORLD, POLY_FULL)
	_set_kind(source, PLATFORM, &"platform", PHYS_PLATFORM, POLY_PLATFORM)
	source.get_tile_data(PLATFORM, 0).set_collision_polygon_one_way(PHYS_PLATFORM, 0, true)
	_set_kind(source, SLOPE_UP_RIGHT, &"slope", PHYS_WORLD, POLY_SLOPE_UP_RIGHT)
	_set_kind(source, SLOPE_UP_LEFT, &"slope", PHYS_WORLD, POLY_SLOPE_UP_LEFT)
	# Spikes are flush with the floor: you stand on them (world) and they hurt (hazard).
	_set_kind(source, HAZARD, &"hazard", PHYS_WORLD, POLY_FULL)
	_add_polygon(source.get_tile_data(HAZARD, 0), PHYS_HAZARD, POLY_FULL)
	_set_kind(source, BREAKABLE, &"breakable", PHYS_WORLD, POLY_FULL)
	source.get_tile_data(BREAKABLE, 0).set_custom_data("breakable", BRICK_HITS)
	_set_kind(source, WATER, &"water", -1, PackedVector2Array())
	_set_kind(source, BACK_WALL, &"wall", -1, PackedVector2Array())

	# Solid is a terrain brush, so blockouts can be painted with the terrain tool.
	var solid: TileData = source.get_tile_data(SOLID, 0)
	solid.terrain_set = 0
	solid.terrain = 0
	for bit: TileSet.CellNeighbor in [
			TileSet.CELL_NEIGHBOR_RIGHT_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
			TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
			TileSet.CELL_NEIGHBOR_LEFT_SIDE, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
			TileSet.CELL_NEIGHBOR_TOP_SIDE, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER]:
		solid.set_terrain_peering_bit(bit, 0)
	# The hidden breakable wall: the solid tile's art, its own data, never picked by the
	# terrain brush (paint it from the alternatives).
	source.create_alternative_tile(SOLID, HIDDEN_BREAKABLE_ALT)
	var hidden: TileData = source.get_tile_data(SOLID, HIDDEN_BREAKABLE_ALT)
	hidden.set_custom_data("kind", &"solid")
	hidden.set_custom_data("breakable", HIDDEN_HITS)
	_add_polygon(hidden, PHYS_WORLD, POLY_FULL)
	return tile_set


func _set_kind(source: TileSetAtlasSource, coords: Vector2i, kind: StringName, physics_layer: int, polygon: PackedVector2Array) -> void:
	var data: TileData = source.get_tile_data(coords, 0)
	data.set_custom_data("kind", kind)
	if physics_layer >= 0:
		_add_polygon(data, physics_layer, polygon)


func _add_polygon(data: TileData, physics_layer: int, polygon: PackedVector2Array) -> void:
	data.add_collision_polygon(physics_layer)
	var index: int = data.get_collision_polygons_count(physics_layer) - 1
	data.set_collision_polygon_points(physics_layer, index, polygon)


func _draw_atlas() -> Image:
	var image: Image = Image.create_empty(TILE * TILE_COUNT, TILE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	_draw_block(image, SOLID.x * TILE, C_FILL)
	# Platform: lit top edge over a thin plank.
	image.fill_rect(Rect2i(PLATFORM.x * TILE, 0, TILE, 2), C_PLATFORM)
	image.fill_rect(Rect2i(PLATFORM.x * TILE, 2, TILE, 4), C_LIGHT)
	image.fill_rect(Rect2i(PLATFORM.x * TILE, 6, TILE, 1), C_DARK)
	# Slopes: solid below the diagonal, lit along it.
	for x: int in TILE:
		for y: int in TILE:
			if y >= TILE - 1 - x:
				image.set_pixel(SLOPE_UP_RIGHT.x * TILE + x, y, C_LIGHT if y == TILE - 1 - x else C_FILL)
			if y >= x:
				image.set_pixel(SLOPE_UP_LEFT.x * TILE + x, y, C_LIGHT if y == x else C_FILL)
	# Hazard: four spikes filling the tile above a dark base.
	image.fill_rect(Rect2i(HAZARD.x * TILE, 12, TILE, 4), C_SPIKE_BASE)
	for spike: int in 4:
		for row: int in 12:
			var width: int = 2 if row >= 6 else 1
			var left: int = HAZARD.x * TILE + spike * 4 + (1 if width == 2 else 2)
			image.fill_rect(Rect2i(left, row, width, 1), C_SPIKE)
	# Breakable: brick with a jagged crack.
	_draw_block(image, BREAKABLE.x * TILE, C_BRICK)
	for i: int in 10:
		image.set_pixel(BREAKABLE.x * TILE + 3 + i, 3 + i + (1 if i % 3 == 2 else 0), C_CRACK)
	# Water: translucent with a bright surface line.
	image.fill_rect(Rect2i(WATER.x * TILE, 1, TILE, TILE - 1), C_WATER)
	image.fill_rect(Rect2i(WATER.x * TILE, 0, TILE, 1), C_WATER_TOP)
	# Back wall: dark brick courses.
	image.fill_rect(Rect2i(BACK_WALL.x * TILE, 0, TILE, TILE), C_DEEP)
	for y: int in [0, 8]:
		image.fill_rect(Rect2i(BACK_WALL.x * TILE, y, TILE, 1), C_DARK)
	image.fill_rect(Rect2i(BACK_WALL.x * TILE + 4, 1, 1, 7), C_DARK)
	image.fill_rect(Rect2i(BACK_WALL.x * TILE + 12, 9, 1, 7), C_DARK)
	return image


func _draw_block(image: Image, left: int, fill: Color) -> void:
	image.fill_rect(Rect2i(left, 0, TILE, TILE), fill)
	image.fill_rect(Rect2i(left, 0, TILE, 1), C_LIGHT)
	image.fill_rect(Rect2i(left, TILE - 1, TILE, 1), C_DARK)
	image.fill_rect(Rect2i(left + TILE - 1, 1, 1, TILE - 1), C_DARK)
	image.fill_rect(Rect2i(left, 8, TILE, 1), C_DARK)
