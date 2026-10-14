extends GutTest
## PIPE-004: SheetPacker frame order, pivot placement, clipping warnings and layout.

const CELL: Vector2i = Vector2i(16, 16)
const CELL_PIVOT: Vector2i = Vector2i(8, 15)


## A transparent frame of [param size] with one red pixel at [param marker].
func _frame(size: Vector2i, marker: Vector2i) -> Image:
	var image: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	image.set_pixelv(marker, Color.RED)
	return image


func test_rows_follow_animation_order_and_columns_fit_longest() -> void:
	var animations: Dictionary[StringName, Array] = {
		&"idle": [_frame(Vector2i(8, 8), Vector2i(4, 7)), _frame(Vector2i(8, 8), Vector2i(4, 7))],
		&"walk": [_frame(Vector2i(8, 8), Vector2i(4, 7)), _frame(Vector2i(8, 8), Vector2i(4, 7)), _frame(Vector2i(8, 8), Vector2i(4, 7))],
	}
	var result: SheetPacker.Result = SheetPacker.pack(animations, {}, CELL, CELL_PIVOT)
	assert_eq(result.image.get_size(), Vector2i(3 * CELL.x, 2 * CELL.y))
	assert_eq(result.layout["columns"], 3)
	assert_eq(result.layout["rows"], 2)
	assert_eq(result.layout["animations"]["idle"], {"row": 0, "frames": 2})
	assert_eq(result.layout["animations"]["walk"], {"row": 1, "frames": 3})
	assert_eq(result.warnings.size(), 0)


func test_source_pivot_lands_on_cell_pivot() -> void:
	# Frames of different canvas sizes, each with its own pivot marked in red.
	var animations: Dictionary[StringName, Array] = {
		&"small": [_frame(Vector2i(6, 10), Vector2i(3, 9))],
		&"large": [_frame(Vector2i(12, 14), Vector2i(5, 12)), _frame(Vector2i(12, 14), Vector2i(5, 12))],
	}
	var pivots: Dictionary[StringName, Vector2i] = {&"small": Vector2i(3, 9), &"large": Vector2i(5, 12)}
	var result: SheetPacker.Result = SheetPacker.pack(animations, pivots, CELL, CELL_PIVOT)
	assert_eq(result.image.get_pixelv(CELL_PIVOT), Color.RED, "small frame 0")
	assert_eq(result.image.get_pixelv(Vector2i(0, CELL.y) + CELL_PIVOT), Color.RED, "large frame 0")
	assert_eq(result.image.get_pixelv(Vector2i(CELL.x, CELL.y) + CELL_PIVOT), Color.RED, "large frame 1")


func test_default_pivot_is_bottom_centre() -> void:
	var animations: Dictionary[StringName, Array] = {&"idle": [_frame(Vector2i(8, 8), Vector2i(4, 7))]}
	var result: SheetPacker.Result = SheetPacker.pack(animations, {}, CELL, CELL_PIVOT)
	# Bottom-centre of an 8x8 frame is (4, 8), so pixel (4, 7) lands one row above the pivot.
	assert_eq(result.image.get_pixelv(CELL_PIVOT + Vector2i(0, -1)), Color.RED)


func test_clipped_frames_are_reported() -> void:
	# Marker far from the pivot, so it falls outside the cell.
	var animations: Dictionary[StringName, Array] = {&"attack": [_frame(Vector2i(40, 16), Vector2i(39, 8))]}
	var pivots: Dictionary[StringName, Vector2i] = {&"attack": Vector2i(8, 15)}
	var result: SheetPacker.Result = SheetPacker.pack(animations, pivots, CELL, CELL_PIVOT)
	assert_eq(result.warnings.size(), 1)
	assert_string_contains(result.warnings[0], "attack frame 0")


func test_save_writes_png_and_json() -> void:
	var animations: Dictionary[StringName, Array] = {&"idle": [_frame(Vector2i(8, 8), Vector2i(4, 7))]}
	var result: SheetPacker.Result = SheetPacker.pack(animations, {}, CELL, CELL_PIVOT)
	var png_path: String = "user://test_sheet_packer.png"
	var json_path: String = "user://test_sheet_packer.json"
	assert_eq(SheetPacker.save(result, png_path, json_path), OK)
	assert_eq(Image.load_from_file(png_path).get_size(), result.image.get_size())
	var layout: Variant = JSON.parse_string(FileAccess.get_file_as_string(json_path))
	assert_true(layout is Dictionary)
	assert_eq((layout as Dictionary)["animations"]["idle"]["frames"], 1.0)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(png_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(json_path))
