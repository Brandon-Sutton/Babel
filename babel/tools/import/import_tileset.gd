extends SceneTree
## PIPE-006: imports a PixelLab sidescroller tileset (16 corner-based "Wang" tiles) into a
## Godot TileSet, driven by an import.json recipe next to the downloaded files:
##
##   {"slug": "gte_solid", "image": "tileset.png", "metadata": "metadata.json",
##    "output_dir": "res://assets/tilesets/gte", "terrain_name": "gte_lapis_brick",
##    "kind": "solid"}
##
## Each tile's corners are "lower" (the solid material) or "upper" (air). That maps onto a
## MATCH_CORNERS terrain set, so painting the terrain autotiles. Collision is built from
## the corners, not the pixels: every solid corner fills its 8x8 quadrant and quadrants
## merge into clean outlines, giving flat, grid-aligned floors and walls even where the
## art's surface decoration is irregular. The all-air tile is skipped.
##
## Outputs <output_dir>/<slug>.png and <slug>.tres (physics layer 0 = "world", custom
## data "kind"). The TileSet needs the PNG imported, so the first run may ask for an
## import and a second run. Re-running gives identical files.
##
## Usage, from the repo root:
##   godot --headless --path babel -s res://tools/import/import_tileset.gd -- res://art_src/pixellab/tilesets/gte_solid/import.json

const WORLD_LAYER_BIT: int = 1 << 0
const CORNER_BITS: Dictionary[String, TileSet.CellNeighbor] = {
	"NW": TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
	"NE": TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
	"SW": TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
	"SE": TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
}
## Quadrant origin (in tile pixels, for a 16 px tile scaled by tile_size / 16) per corner.
const CORNER_QUADRANT: Dictionary[String, Vector2i] = {
	"NW": Vector2i(0, 0), "NE": Vector2i(1, 0), "SW": Vector2i(0, 1), "SE": Vector2i(1, 1),
}


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() != 1:
		printerr("usage: -- <path to import.json>")
		quit(1)
		return
	quit(0 if _import(args[0]) else 1)


func _import(recipe_path: String) -> bool:
	var recipe: Dictionary = _read_json(recipe_path)
	if recipe.is_empty():
		return false
	var base_dir: String = recipe_path.get_base_dir()
	var metadata: Dictionary = _read_json(base_dir.path_join(recipe.get("metadata", "metadata.json")))
	if metadata.is_empty():
		return false
	var source_png: String = ProjectSettings.globalize_path(base_dir.path_join(recipe.get("image", "tileset.png")))
	var output_dir: String = recipe["output_dir"]
	var slug: String = recipe["slug"]
	var png_path: String = output_dir.path_join(slug + ".png")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	if _copy_if_changed(source_png, ProjectSettings.globalize_path(png_path)) \
			or not FileAccess.file_exists(png_path + ".import"):
		print("import_tileset: copied %s. Run --import, then run this importer again." % png_path)
		return true

	var data: Dictionary = metadata["tileset_data"]
	var tile_px: int = int(data["tile_size"]["width"]) if data["tile_size"] is Dictionary else int(data["tile_size"])
	var tile_set: TileSet = TileSet.new()
	tile_set.tile_size = Vector2i(tile_px, tile_px)
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(0, WORLD_LAYER_BIT)
	tile_set.set_physics_layer_collision_mask(0, 0)
	tile_set.add_custom_data_layer()
	tile_set.set_custom_data_layer_name(0, "kind")
	tile_set.set_custom_data_layer_type(0, TYPE_STRING_NAME)
	tile_set.add_terrain_set()
	tile_set.set_terrain_set_mode(0, TileSet.TERRAIN_MODE_MATCH_CORNERS)
	tile_set.add_terrain(0)
	tile_set.set_terrain_name(0, 0, recipe.get("terrain_name", slug))
	tile_set.set_terrain_color(0, 0, Color("3d64b5"))

	var source: TileSetAtlasSource = TileSetAtlasSource.new()
	source.texture = load(png_path)
	source.texture_region_size = Vector2i(tile_px, tile_px)
	tile_set.add_source(source, 0)

	var kind: StringName = StringName(recipe.get("kind", "solid"))
	var created: int = 0
	for tile: Dictionary in data["tiles"]:
		var corners: Dictionary = tile["corners"]
		var solid: PackedStringArray = []
		for corner: String in CORNER_BITS:
			if corners[corner] == "lower":
				solid.append(corner)
		if solid.is_empty():
			continue
		var box: Dictionary = tile["bounding_box"]
		var coords: Vector2i = Vector2i(int(box["x"]) / tile_px, int(box["y"]) / tile_px)
		source.create_tile(coords)
		var tile_data: TileData = source.get_tile_data(coords, 0)
		tile_data.set_custom_data("kind", kind)
		tile_data.terrain_set = 0
		tile_data.terrain = 0
		for corner: String in solid:
			tile_data.set_terrain_peering_bit(CORNER_BITS[corner], 0)
		for polygon: PackedVector2Array in _corner_polygons(solid, tile_px):
			tile_data.add_collision_polygon(0)
			tile_data.set_collision_polygon_points(0, tile_data.get_collision_polygons_count(0) - 1, polygon)
		created += 1

	var tres_path: String = output_dir.path_join(slug + ".tres")
	var err: Error = ResourceSaver.save(tile_set, tres_path)
	if err != OK:
		printerr("import_tileset: writing %s failed: %s" % [tres_path, error_string(err)])
		return false
	print("import_tileset: wrote %s (%d tiles, corner terrain '%s')" % [tres_path, created, tile_set.get_terrain_name(0, 0)])
	return true


## Merged collision outlines (tile-centred coordinates) for the solid corner quadrants.
func _corner_polygons(solid: PackedStringArray, tile_px: int) -> Array[PackedVector2Array]:
	var half: int = tile_px >> 1
	var mask: BitMap = BitMap.new()
	mask.create(Vector2i(tile_px, tile_px))
	for corner: String in solid:
		var quadrant: Vector2i = CORNER_QUADRANT[corner] * half
		mask.set_bit_rect(Rect2i(quadrant, Vector2i(half, half)), true)
	var polygons: Array[PackedVector2Array] = []
	for outline: PackedVector2Array in mask.opaque_to_polygons(Rect2i(0, 0, tile_px, tile_px), 0.5):
		var centred: PackedVector2Array = []
		for point: Vector2 in outline:
			centred.append(point - Vector2(half, half))
		polygons.append(centred)
	return polygons


## Copies [param from] to [param to] unless identical. Returns true if it wrote.
func _copy_if_changed(from: String, to: String) -> bool:
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(from)
	if FileAccess.file_exists(to) and FileAccess.get_file_as_bytes(to) == bytes:
		return false
	var file: FileAccess = FileAccess.open(to, FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()
	return true


func _read_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		printerr("import_tileset: cannot read JSON object from ", path)
		return {}
	return parsed
