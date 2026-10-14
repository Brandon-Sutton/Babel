extends SceneTree
## Builds a review sheet of sprites for art approval (ART_BIBLE §7.3 review gate): each
## image upscaled with nearest-neighbour in a top row, the same images at 1x underneath,
## on the game's clear colour. Inputs are bottom-aligned so heights compare honestly.
##
## Usage, from the repo root (paths are OS paths; everything after -- is for this tool):
##   godot --headless --path babel -s res://tools/import/contact_sheet.gd -- <out.png> <scale> <img>...

const BACKGROUND: Color = Color(0.043, 0.039, 0.063)
const GAP: int = 16


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() < 3:
		printerr("usage: -- <out.png> <scale> <img>...")
		quit(1)
		return
	var scale: int = maxi(1, args[1].to_int())
	var images: Array[Image] = []
	for path: String in args.slice(2):
		var image: Image = Image.load_from_file(path)
		if image == null:
			printerr("contact_sheet: cannot load ", path)
			quit(1)
			return
		image.convert(Image.FORMAT_RGBA8)
		images.append(image)
		var used: Rect2i = image.get_used_rect()
		print("contact_sheet: %s canvas %dx%d, drawn %dx%d at %s" % [
			path.get_file(), image.get_width(), image.get_height(), used.size.x, used.size.y, used.position])

	var max_h: int = 0
	var total_w: int = GAP
	for image: Image in images:
		max_h = maxi(max_h, image.get_height())
		total_w += image.get_width() * scale + GAP
	var sheet: Image = Image.create_empty(total_w, max_h * scale + max_h + GAP * 3, false, Image.FORMAT_RGBA8)
	sheet.fill(BACKGROUND)

	var x: int = GAP
	for image: Image in images:
		var big: Image = image.duplicate() as Image
		big.resize(image.get_width() * scale, image.get_height() * scale, Image.INTERPOLATE_NEAREST)
		var big_y: int = GAP + (max_h - image.get_height()) * scale
		sheet.blend_rect(big, Rect2i(Vector2i.ZERO, big.get_size()), Vector2i(x, big_y))
		var small_y: int = GAP * 2 + max_h * scale + (max_h - image.get_height())
		sheet.blend_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i(x, small_y))
		x += big.get_width() + GAP
	var err: Error = sheet.save_png(args[0])
	if err != OK:
		printerr("contact_sheet: cannot write %s: %s" % [args[0], error_string(err)])
		quit(1)
		return
	print("contact_sheet: wrote ", args[0])
	quit()
