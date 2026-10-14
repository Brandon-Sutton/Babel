extends SceneTree
## PIPE-002: palette utilities. Paths are OS paths; everything after -- is for this tool.
##
##   extract <out_base> <img>...  Every opaque colour in the images (union), most-used
##                                first: <out_base>.png (16-wide grid, 1 px per colour),
##                                <out_base>.hex (Lospec format), plus a usage report.
##                                Use it for per-character palettes that lock animation
##                                frames with PixelLab reduce_colors.
##   gpl <in.gpl> <out_base>      Converts a curated GIMP palette to <out_base>.png (one
##                                row per ramp, ramps named "<ramp>_<n>") and .hex.
##
## Usage, from the repo root:
##   godot --headless --path babel -s res://tools/import/palette_tool.gd -- extract <out_base> <img>...

const GRID_WIDTH: int = 16


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var ok: bool = false
	if args.size() >= 3 and args[0] == "extract":
		ok = _extract(args[1], args.slice(2))
	elif args.size() == 3 and args[0] == "gpl":
		ok = _from_gpl(args[1], args[2])
	else:
		printerr("usage: -- extract <out_base> <img>...  |  -- gpl <in.gpl> <out_base>")
	quit(0 if ok else 1)


func _extract(out_base: String, paths: PackedStringArray) -> bool:
	var counts: Dictionary[int, int] = {}
	for path: String in paths:
		var image: Image = Image.load_from_file(path)
		if image == null:
			printerr("palette_tool: cannot load ", path)
			return false
		image.convert(Image.FORMAT_RGBA8)
		for y: int in image.get_height():
			for x: int in image.get_width():
				var color: Color = image.get_pixel(x, y)
				if color.a8 == 255:
					var rgba: int = color.to_rgba32()
					counts[rgba] = counts.get(rgba, 0) + 1
	var colors: Array[int] = counts.keys()
	colors.sort_custom(func(a: int, b: int) -> bool: return counts[a] > counts[b])
	var swatches: Array[Color] = []
	for rgba: int in colors:
		swatches.append(Color.hex(rgba))
	print("palette_tool: %d colours from %d image(s)" % [colors.size(), paths.size()])
	for rgba: int in colors:
		var c: Color = Color.hex(rgba)
		print("  #%s  x%-4d  h=%3d s=%.2f v=%.2f" % [c.to_html(false), counts[rgba], roundi(c.h * 360.0), c.s, c.v])
	var rows: Array[Array] = []
	for i: int in range(0, swatches.size(), GRID_WIDTH):
		rows.append(swatches.slice(i, i + GRID_WIDTH))
	return _write(out_base, rows)


func _from_gpl(gpl_path: String, out_base: String) -> bool:
	var file: FileAccess = FileAccess.open(gpl_path, FileAccess.READ)
	if file == null:
		printerr("palette_tool: cannot open ", gpl_path)
		return false
	var ramps: Dictionary[String, Array] = {}
	var order: PackedStringArray = []
	while not file.eof_reached():
		var line: String = file.get_line().strip_edges()
		if line.is_empty() or line.begins_with("#") or line.begins_with("GIMP") or ":" in line:
			continue
		var fields: PackedStringArray = line.replace("\t", " ").split(" ", false)
		if fields.size() < 4:
			continue
		var color: Color = Color8(fields[0].to_int(), fields[1].to_int(), fields[2].to_int())
		var ramp: String = fields[3].rsplit("_", true, 1)[0]
		if not ramps.has(ramp):
			ramps[ramp] = []
			order.append(ramp)
		ramps[ramp].append(color)
	var rows: Array[Array] = []
	for ramp: String in order:
		rows.append(ramps[ramp])
		print("  %-12s %d colours" % [ramp, ramps[ramp].size()])
	return _write(out_base, rows)


## Writes rows of colours as a PNG (1 px per colour, transparent padding) and a .hex file.
func _write(out_base: String, rows: Array[Array]) -> bool:
	var width: int = 0
	for row: Array in rows:
		width = maxi(width, row.size())
	var image: Image = Image.create_empty(maxi(width, 1), maxi(rows.size(), 1), false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var hex_lines: PackedStringArray = []
	for y: int in rows.size():
		for x: int in rows[y].size():
			var color: Color = rows[y][x]
			image.set_pixel(x, y, color)
			hex_lines.append(color.to_html(false))
	if image.save_png(out_base + ".png") != OK:
		printerr("palette_tool: cannot write ", out_base, ".png")
		return false
	var hex_file: FileAccess = FileAccess.open(out_base + ".hex", FileAccess.WRITE)
	if hex_file == null:
		printerr("palette_tool: cannot write ", out_base, ".hex")
		return false
	hex_file.store_string("\n".join(hex_lines) + "\n")
	print("palette_tool: wrote %s.png and %s.hex (%d colours)" % [out_base, out_base, hex_lines.size()])
	return true
