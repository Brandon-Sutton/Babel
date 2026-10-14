class_name SheetPacker
## PIPE-004: packs animation frames into a row-per-animation sprite sheet with a fixed
## cell size and a shared pivot (e.g. the character's feet), plus a JSON-ready layout.
## Sprite2D plays the result with hframes = columns, vframes = rows and frame_coords =
## Vector2i(frame, row). Used by the art importers in tools/import/.


## One packed sheet.
class Result:
	## The sheet (RGBA8, transparent background).
	var image: Image
	## Layout for the .json sidecar: cell, pivot, columns, rows and, per animation, its
	## row and frame count.
	var layout: Dictionary = {}
	## Frames whose opaque pixels did not fit in their cell; empty when clean.
	var warnings: PackedStringArray = []


## Packs [param animations] (name -> Array of Image in play order; insertion order sets
## the row order) into cells of [param cell_size]. Every frame is placed so that the
## point [param source_pivots][name] of the frame lands on [param cell_pivot] of its
## cell; animations without an entry use the frame's own bottom-centre.
static func pack(
		animations: Dictionary[StringName, Array],
		source_pivots: Dictionary[StringName, Vector2i],
		cell_size: Vector2i,
		cell_pivot: Vector2i
) -> Result:
	var result: Result = Result.new()
	var columns: int = 1
	for frames: Array in animations.values():
		columns = maxi(columns, frames.size())
	var rows: int = maxi(animations.size(), 1)
	result.image = Image.create_empty(columns * cell_size.x, rows * cell_size.y, false, Image.FORMAT_RGBA8)
	result.image.fill(Color(0, 0, 0, 0))

	var animation_layout: Dictionary = {}
	var row: int = 0
	for anim_name: StringName in animations:
		var frames: Array = animations[anim_name]
		for col: int in frames.size():
			var frame: Image = (frames[col] as Image).duplicate() as Image
			frame.convert(Image.FORMAT_RGBA8)
			var pivot: Vector2i = source_pivots.get(anim_name, Vector2i(floori(frame.get_width() / 2.0), frame.get_height()))
			var cell_rect: Rect2i = Rect2i(Vector2i(col * cell_size.x, row * cell_size.y), cell_size)
			var dest: Vector2i = cell_rect.position + cell_pivot - pivot
			var used: Rect2i = frame.get_used_rect()
			if used.has_area() and not cell_rect.encloses(Rect2i(dest + used.position, used.size)):
				result.warnings.append("%s frame %d: opaque pixels fall outside the %dx%d cell" % [
					anim_name, col, cell_size.x, cell_size.y])
			var visible: Rect2i = Rect2i(dest, frame.get_size()).intersection(cell_rect)
			if visible.has_area():
				result.image.blit_rect(frame, Rect2i(visible.position - dest, visible.size), visible.position)
		animation_layout[String(anim_name)] = {"row": row, "frames": frames.size()}
		row += 1

	result.layout = {
		"cell": [cell_size.x, cell_size.y],
		"pivot": [cell_pivot.x, cell_pivot.y],
		"columns": columns,
		"rows": rows,
		"animations": animation_layout,
	}
	return result


## Writes [param result] as a PNG sheet and a JSON layout sidecar.
static func save(result: Result, png_path: String, json_path: String) -> Error:
	var err: Error = result.image.save_png(png_path)
	if err != OK:
		return err
	var file: FileAccess = FileAccess.open(json_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(result.layout, "\t") + "\n")
	return OK
