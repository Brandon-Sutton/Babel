extends SceneTree
## PIPE-003: imports a PixelLab character export into a fixed-cell sprite sheet and an
## AnimationLibrary, driven by an import.json recipe that sits next to the export:
##
##   {
##     "slug": "elam", "export_dir": "export", "direction": "east",
##     "cell": [128, 128], "cell_pivot": [64, 124],
##     "output_dir": "res://assets/sprites/player/elam", "sprite_node": "Sprite2D",
##     "animations": {
##       "idle": {"source": "idle", "fps": 8, "loop": true, "grounded": true},
##       "slash": {"source": "sword slash", "frame_ms": [60, 60, 40, 40, 80, 80]}
##     }
##   }
##
## "source" is the animation name in the export's metadata.json; rows follow the order in
## "animations". "frames" picks and orders source frames by index, so one PixelLab
## animation can feed several (a jump split into "jump" and "fall"). "frame_ms"
## (per-frame durations) overrides "fps". "grounded" animations are checked to keep the
## feet on the ground line in every frame. "lift" (px) is how far above the feet line
## PixelLab painted an airborne animation (a leap drawn mid-air in its canvas); its
## frames are moved down by that much so the art sits on the body that does the jumping.
## "guide_prop": true marks animations drawn with the key-green rod in Elam's hand
## (EQV-002): the rod is erased from the art, its grip and angle become the `hand_r`
## attach point, and any key-green swing smear goes to <slug>_smear.png.
##
## Every frame also gets body attach points (head, neck, chest, belt, ankles), stored
## per animation as "anchors" in the layout JSON, relative to the feet, facing right.
##
## The feet pivot comes from the rotation for "direction": the bottom of its opaque pixels
## and the centre of the boots. PixelLab grows animation canvases evenly around the
## rotation canvas, so each animation's pivot is the rotation pivot plus half the growth.
##
## Outputs <output_dir>/<slug>.png (sheet), <slug>.json (layout with anchors),
## <slug>_smear.png (when any animation has a smear) and <slug>_anims.tres
## (AnimationLibrary keyed on <sprite_node>:frame_coords). Re-running gives identical files.
## Exits 1 on missing frames, clipped frames or feet that leave the ground line.
##
## Usage, from the repo root:
##   godot --headless --path babel -s res://tools/import/import_character.gd -- res://art_src/pixellab/characters/elam/import.json

## Rows at the bottom of the rotation used to find the boots' centre.
const FEET_ROWS: int = 4
## Allowed vertical drift (px) of the feet in grounded animations.
const GROUND_TOLERANCE: int = 1


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
	var export_dir: String = base_dir.path_join(recipe.get("export_dir", "export"))
	var metadata: Dictionary = _read_json(export_dir.path_join("metadata.json"))
	if metadata.is_empty():
		return false
	var frames_meta: Dictionary = (metadata["states"] as Array)[0]["frames"]
	var direction: String = recipe.get("direction", "east")
	var cell: Vector2i = _vec2i(recipe["cell"])
	var cell_pivot: Vector2i = _vec2i(recipe["cell_pivot"])

	var rotation: Image = _load_image(export_dir.path_join(frames_meta["rotations"][direction]))
	if rotation == null:
		return false
	var rotation_pivot: Vector2i = _feet_pivot(rotation)
	print("import_character: %s rotation %s, feet pivot %s" % [direction, rotation.get_size(), rotation_pivot])

	var animations: Dictionary[StringName, Array] = {}
	var smears: Dictionary[StringName, Array] = {}
	var anchors: Dictionary[StringName, Array] = {}
	var has_smear: bool = false
	var pivots: Dictionary[StringName, Vector2i] = {}
	var recipe_animations: Dictionary = recipe["animations"]
	for anim_name: String in recipe_animations:
		var spec: Dictionary = recipe_animations[anim_name]
		var source: String = spec.get("source", anim_name)
		var by_direction: Dictionary = frames_meta["animations"].get(source, {})
		if not by_direction.has(direction):
			printerr("import_character: no '%s' frames for animation '%s' in the export" % [direction, source])
			return false
		var frame_paths: Array = by_direction[direction]
		if spec.has("frames"):
			var picked: Array = []
			for index: Variant in spec["frames"]:
				picked.append(frame_paths[int(index)])
			frame_paths = picked
		var frames: Array[Image] = []
		for frame_path: String in frame_paths:
			var frame: Image = _load_image(export_dir.path_join(frame_path))
			if frame == null:
				return false
			frames.append(frame)
		var growth: Vector2i = frames[0].get_size() - rotation.get_size()
		var lift: int = int(spec.get("lift", 0))
		var pivot: Vector2i = rotation_pivot + Vector2i(floori(growth.x / 2.0), floori(growth.y / 2.0) - lift)
		pivots[StringName(anim_name)] = pivot
		var frame_anchors: Array = []
		var frame_smears: Array = []
		if spec.get("guide_prop", false):
			var extracted: Array[GuideProp.Extraction] = GuideProp.extract_animation(frames)
			for i: int in frames.size():
				var e: GuideProp.Extraction = extracted[i]
				frames[i] = e.body
				frame_smears.append(e.smear)
				has_smear = has_smear or e.is_smear
				var hand: Vector2 = e.grip - Vector2(pivot)
				var points: Dictionary = _points_json(GuideProp.body_points(e.body, pivot))
				points["hand_r"] = [snappedf(hand.x, 0.1), snappedf(hand.y, 0.1), roundf(e.angle)]
				points["smear"] = e.is_smear
				frame_anchors.append(points)
			print("import_character: %s guide prop: %s" % [anim_name, _hand_summary(extracted)])
		else:
			for frame: Image in frames:
				frame_anchors.append(_points_json(GuideProp.body_points(frame, pivot)))
				frame_smears.append(Image.create_empty(frame.get_width(), frame.get_height(), false, Image.FORMAT_RGBA8))
		animations[StringName(anim_name)] = frames
		smears[StringName(anim_name)] = frame_smears
		anchors[StringName(anim_name)] = frame_anchors

	var packed: SheetPacker.Result = SheetPacker.pack(animations, pivots, cell, cell_pivot)
	var ok: bool = packed.warnings.is_empty()
	for warning: String in packed.warnings:
		printerr("import_character: ", warning)
	ok = _check_grounded(packed, recipe_animations, cell, cell_pivot) and ok

	var slug: String = recipe["slug"]
	var output_dir: String = recipe["output_dir"]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	for anim_name: String in recipe_animations:
		var spec: Dictionary = recipe_animations[anim_name]
		var entry: Dictionary = packed.layout["animations"][anim_name]
		entry["frame_ms"] = _frame_durations_ms(spec, entry["frames"])
		entry["loop"] = spec.get("loop", false)
		entry["anchors"] = anchors[StringName(anim_name)]
		entry["hands"] = spec.get("guide_prop", false)
	var err: Error = SheetPacker.save(packed, ProjectSettings.globalize_path(output_dir.path_join(slug + ".png")),
			ProjectSettings.globalize_path(output_dir.path_join(slug + ".json")))
	if err != OK:
		printerr("import_character: writing the sheet failed: ", error_string(err))
		return false
	var smear_path: String = ProjectSettings.globalize_path(output_dir.path_join(slug + "_smear.png"))
	if has_smear:
		err = SheetPacker.pack(smears, pivots, cell, cell_pivot).image.save_png(smear_path)
		if err != OK:
			printerr("import_character: writing the smear sheet failed: ", error_string(err))
			return false
	elif FileAccess.file_exists(smear_path):
		DirAccess.remove_absolute(smear_path)
	var library_path: String = output_dir.path_join(slug + "_anims.tres")
	err = ResourceSaver.save(_build_library(packed.layout, recipe.get("sprite_node", "Sprite2D")), library_path)
	if err != OK:
		printerr("import_character: writing %s failed: %s" % [library_path, error_string(err)])
		return false
	print("import_character: wrote %s.png (%dx%d, %d animation(s)), %s.json, %s_anims.tres" % [
		slug, packed.image.get_width(), packed.image.get_height(), recipe_animations.size(), slug, slug])
	return ok


## Feet pivot: one pixel below the lowest opaque row, horizontally at the centre of the
## opaque pixels in the bottom FEET_ROWS rows (the boots, ignoring cape and hair).
func _feet_pivot(image: Image) -> Vector2i:
	var used: Rect2i = image.get_used_rect()
	var bottom: int = used.end.y
	var sum_x: int = 0
	var count: int = 0
	for y: int in range(maxi(bottom - FEET_ROWS, used.position.y), bottom):
		for x: int in range(used.position.x, used.end.x):
			if image.get_pixel(x, y).a8 > 0:
				sum_x += x
				count += 1
	var feet_x: int = roundi(float(sum_x) / count) if count > 0 else used.get_center().x
	return Vector2i(feet_x, bottom)


func _points_json(points: Dictionary[StringName, Vector2]) -> Dictionary:
	var json: Dictionary = {}
	for key: StringName in points:
		json[String(key)] = [snappedf(points[key].x, 0.1), snappedf(points[key].y, 0.1)]
	return json


func _hand_summary(extracted: Array[GuideProp.Extraction]) -> String:
	var parts: PackedStringArray = []
	for e: GuideProp.Extraction in extracted:
		parts.append("smear" if e.is_smear else ("%d deg" % roundi(e.angle) if e.has_rod else "no rod"))
	return ", ".join(parts)


## Grounded animations must keep their lowest opaque row on the ground line in each cell.
func _check_grounded(packed: SheetPacker.Result, recipe_animations: Dictionary, cell: Vector2i, cell_pivot: Vector2i) -> bool:
	var ok: bool = true
	for anim_name: String in recipe_animations:
		if not recipe_animations[anim_name].get("grounded", false):
			continue
		var entry: Dictionary = packed.layout["animations"][anim_name]
		var worst: int = 0
		for col: int in entry["frames"]:
			var region: Rect2i = Rect2i(Vector2i(col * cell.x, int(entry["row"]) * cell.y), cell)
			var used: Rect2i = packed.image.get_region(region).get_used_rect()
			worst = maxi(worst, absi(used.end.y - cell_pivot.y))
		var verdict: String = "ok" if worst <= GROUND_TOLERANCE else "FAIL"
		print("import_character: %s feet within %d px of the ground line (%s)" % [anim_name, worst, verdict])
		ok = ok and worst <= GROUND_TOLERANCE
	return ok


func _frame_durations_ms(spec: Dictionary, frame_count: int) -> Array[int]:
	var durations: Array[int] = []
	if spec.has("frame_ms"):
		for ms: Variant in spec["frame_ms"]:
			durations.append(int(ms))
		if durations.size() != frame_count:
			push_warning("import_character: frame_ms has %d entries for %d frames" % [durations.size(), frame_count])
		durations.resize(frame_count)
		return durations
	var ms_per_frame: int = roundi(1000.0 / float(spec.get("fps", 10)))
	for i: int in frame_count:
		durations.append(ms_per_frame)
	return durations


func _build_library(layout: Dictionary, sprite_node: String) -> AnimationLibrary:
	var library: AnimationLibrary = AnimationLibrary.new()
	var animations: Dictionary = layout["animations"]
	for anim_name: String in animations:
		var entry: Dictionary = animations[anim_name]
		var animation: Animation = Animation.new()
		var track: int = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track, NodePath(sprite_node + ":frame_coords"))
		animation.value_track_set_update_mode(track, Animation.UPDATE_DISCRETE)
		animation.track_set_interpolation_type(track, Animation.INTERPOLATION_NEAREST)
		var time_ms: int = 0
		var durations: Array = entry["frame_ms"]
		for col: int in durations.size():
			animation.track_insert_key(track, time_ms / 1000.0, Vector2i(col, int(entry["row"])))
			time_ms += int(durations[col])
		animation.length = time_ms / 1000.0
		animation.loop_mode = Animation.LOOP_LINEAR if entry["loop"] else Animation.LOOP_NONE
		library.add_animation(StringName(anim_name), animation)
	return library


func _read_json(path: String) -> Dictionary:
	var text: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		printerr("import_character: cannot read JSON object from ", path)
		return {}
	return parsed


func _load_image(path: String) -> Image:
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null:
		printerr("import_character: cannot load ", path)
		return null
	image.convert(Image.FORMAT_RGBA8)
	return image


func _vec2i(value: Variant) -> Vector2i:
	var pair: Array = value
	return Vector2i(int(pair[0]), int(pair[1]))
