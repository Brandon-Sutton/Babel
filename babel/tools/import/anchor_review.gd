extends SceneTree
## EQV-003: review sheet for a character's attach points. Draws every frame of the
## imported sheet at [scale] with its anchors: the hand grip as a red box with a yellow
## blade line, body points as coloured dots, and smear frames tinted from the smear sheet.
##   godot --headless --path babel -s res://tools/import/anchor_review.gd -- <sprite_dir> <slug> <out.png> [scale]

const COLORS: Dictionary[String, Color] = {
	"head": Color("ffd23c"), "neck": Color("ff8c3c"), "chest": Color("3cc8ff"),
	"belt": Color("b45aff"), "ankle_f": Color("3cff8c"), "ankle_b": Color("1e9650"),
}


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() < 3:
		printerr("usage: -- <sprite_dir> <slug> <out.png> [scale]")
		quit(1)
		return
	var dir: String = args[0]
	var slug: String = args[1]
	var scale: int = int(args[3]) if args.size() > 3 else 2
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(dir.path_join(slug + ".json")))
	var sheet: Image = Image.load_from_file(ProjectSettings.globalize_path(dir.path_join(slug + ".png")))
	var smear_path: String = ProjectSettings.globalize_path(dir.path_join(slug + "_smear.png"))
	var smear: Image = Image.load_from_file(smear_path) if FileAccess.file_exists(smear_path) else null
	sheet.convert(Image.FORMAT_RGBA8)
	var cell: Vector2i = Vector2i(int(layout["cell"][0]), int(layout["cell"][1]))
	var pivot: Vector2i = Vector2i(int(layout["pivot"][0]), int(layout["pivot"][1]))
	var columns: int = int(layout["columns"])
	var rows: int = int(layout["rows"])
	var out: Image = Image.create_empty(columns * cell.x * scale, rows * cell.y * scale, false, Image.FORMAT_RGBA8)
	out.fill(Color("26262e"))
	var animations: Dictionary = layout["animations"]
	for anim_name: String in animations:
		var entry: Dictionary = animations[anim_name]
		var row: int = int(entry["row"])
		var anchors: Array = entry.get("anchors", [])
		for col: int in int(entry["frames"]):
			var origin: Vector2i = Vector2i(col * cell.x, row * cell.y)
			var frame: Image = sheet.get_region(Rect2i(origin, cell))
			if smear != null:
				var smear_frame: Image = smear.get_region(Rect2i(origin, cell))
				smear_frame.convert(Image.FORMAT_RGBA8)
				for y: int in cell.y:
					for x: int in cell.x:
						var s: Color = smear_frame.get_pixel(x, y)
						if s.a8 > 0:
							frame.set_pixel(x, y, Color(s.r * 0.9, s.g * 0.5, s.b, 1.0))
			frame.resize(cell.x * scale, cell.y * scale, Image.INTERPOLATE_NEAREST)
			var at: Vector2i = origin * scale
			out.blend_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), at)
			if col >= anchors.size():
				continue
			var points: Dictionary = anchors[col]
			var feet: Vector2 = Vector2(pivot)
			for key: String in COLORS:
				if points.has(key):
					_dot(out, at, (feet + _vec(points[key])) * scale, COLORS[key], 2)
			if points.has("hand_r"):
				var hand: Array = points["hand_r"]
				var grip: Vector2 = (feet + Vector2(float(hand[0]), float(hand[1]))) * scale
				var blade: Vector2 = Vector2.from_angle(deg_to_rad(float(hand[2])))
				for i: int in 30 * scale:
					_dot(out, at, grip + blade * i, Color("ffe600"), 0)
				_dot(out, at, grip, Color("ff3c3c") if not points.get("smear", false) else Color("ff3cff"), 3)
	out.save_png(args[2])
	print("anchor_review: wrote ", args[2])
	quit(0)


func _vec(value: Variant) -> Vector2:
	var pair: Array = value
	return Vector2(float(pair[0]), float(pair[1]))


func _dot(image: Image, origin: Vector2i, at: Vector2, color: Color, radius: int) -> void:
	for dy: int in range(-radius, radius + 1):
		for dx: int in range(-radius, radius + 1):
			var p: Vector2i = origin + Vector2i(roundi(at.x), roundi(at.y)) + Vector2i(dx, dy)
			if p.x >= 0 and p.y >= 0 and p.x < image.get_width() and p.y < image.get_height():
				image.set_pixelv(p, color)
