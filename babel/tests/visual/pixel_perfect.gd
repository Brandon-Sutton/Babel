extends Node2D
## VFX-001: pixel-perfect rendering check. A checkerboard and a small sprite placed at a
## fractional position, seen through a camera panning at a sub-pixel speed (37 px/s).
## On a few frames it reads back the rendered image and verifies every pixel is one of
## the source colours: no texture filtering, blending or sub-pixel smearing.
## Logs "VISUAL PASS"/"VISUAL FAIL". Needs a real window: run it via tools/capture.sh.

const CELL: int = 8
const WORLD_SIZE: Vector2i = Vector2i(2400, 360)
const PAN_SPEED: float = 37.0
const CHECK_FRAMES: PackedInt32Array = [30, 61, 97]

# Colours from the ART_BIBLE master ramps, defined as exact 8-bit values.
const BITUMEN: Color = Color(36.0 / 255.0, 30.0 / 255.0, 46.0 / 255.0)
const BITUMEN_LIGHT: Color = Color(58.0 / 255.0, 48.0 / 255.0, 71.0 / 255.0)
const OUTLINE: Color = Color(11.0 / 255.0, 10.0 / 255.0, 16.0 / 255.0)
const LAPIS: Color = Color(44.0 / 255.0, 74.0 / 255.0, 154.0 / 255.0)
const GOLD: Color = Color(224.0 / 255.0, 179.0 / 255.0, 74.0 / 255.0)
const CRIMSON: Color = Color(192.0 / 255.0, 38.0 / 255.0, 60.0 / 255.0)
const BONE: Color = Color(232.0 / 255.0, 223.0 / 255.0, 196.0 / 255.0)

var _frame: int = 0
var _failures: int = 0

@onready var _camera: Camera2D = $Camera2D


func _ready() -> void:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = _make_sprite_texture()
	sprite.position = Vector2(300.5, 180.25)
	add_child(sprite)
	var window: Window = get_window()
	var scale_factor: int = mini(
			floori(float(window.size.x) / window.content_scale_size.x),
			floori(float(window.size.y) / window.content_scale_size.y))
	print("VISUAL window=%s content=%s integer_scale=%dx" % [window.size, window.content_scale_size, scale_factor])


func _process(delta: float) -> void:
	_camera.position.x += PAN_SPEED * delta
	_frame += 1
	if _frame in CHECK_FRAMES:
		_verify_frame()


func _draw() -> void:
	for y: int in range(0, WORLD_SIZE.y, CELL):
		for x: int in range(0, WORLD_SIZE.x, CELL):
			var even: bool = ((x ^ y) & CELL) == 0  # CELL is a power of two
			draw_rect(Rect2(x, y, CELL, CELL), BITUMEN if even else BITUMEN_LIGHT)


func _verify_frame() -> void:
	# With HDR 2D the viewport holds linear floats; convert back to sRGB before comparing.
	var image: Image = get_viewport().get_texture().get_image()
	var linear: bool = get_viewport().use_hdr_2d
	var allowed: Dictionary[int, bool] = {}
	for color: Color in [BITUMEN, BITUMEN_LIGHT, OUTLINE, LAPIS, GOLD, CRIMSON, BONE]:
		allowed[color.to_rgba32()] = true
	var stray: Dictionary[int, int] = {}
	for y: int in image.get_height():
		for x: int in image.get_width():
			var pixel: Color = image.get_pixel(x, y)
			var rgba: int = (pixel.linear_to_srgb() if linear else pixel).to_rgba32()
			if not allowed.has(rgba):
				stray[rgba] = stray.get(rgba, 0) + 1
	if stray.is_empty():
		print("VISUAL PASS frame %d (camera x=%.2f): %dx%d, only source colours." % [
			_frame, _camera.position.x, image.get_width(), image.get_height()])
		return
	_failures += 1
	var examples: PackedStringArray = []
	for rgba: int in stray.keys().slice(0, 5):
		examples.append("#%08x x%d" % [rgba, stray[rgba]])
	print("VISUAL FAIL frame %d: %d stray colours, e.g. %s" % [_frame, stray.size(), ", ".join(examples)])


func _make_sprite_texture() -> ImageTexture:
	var image: Image = Image.create_empty(16, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	image.fill_rect(Rect2i(0, 0, 16, 32), OUTLINE)
	image.fill_rect(Rect2i(1, 1, 14, 30), LAPIS)
	image.fill_rect(Rect2i(3, 3, 4, 26), GOLD)
	image.fill_rect(Rect2i(9, 6, 4, 4), CRIMSON)
	image.fill_rect(Rect2i(10, 20, 2, 8), BONE)
	return ImageTexture.create_from_image(image)
