extends SceneTree
## EQV-008: draws the first batch of worn-equipment sprites (GDD §6.7), writes their
## WornArt resources and links them, plus body and mantle dyes, to the items. The pixel
## art is drawn from code so it is reproducible; PixelLab art can replace a PNG later
## without touching the data.
##
## Run it twice: the first run writes the PNGs and asks for --import; the second writes
## the WornArt resources and updates the item .tres files.
##   godot --headless --path babel -s res://tools/builders/build_worn_art.gd

const OUT: String = "res://assets/sprites/items/worn"

const OUTLINE: Color = Color("1a1420")
const STEEL_LIGHT: Color = Color("f0eef8")
const STEEL: Color = Color("b8b4c8")
const STEEL_DARK: Color = Color("6e6a84")
const GOLD_LIGHT: Color = Color("f4d68a")
const GOLD: Color = Color("c59c5c")
const GOLD_DARK: Color = Color("82633f")
const GRIP: Color = Color("6b4a32")
const GRIP_DARK: Color = Color("3e2a1c")
const WOOD_LIGHT: Color = Color("9a7450")
const WOOD: Color = Color("6b4a32")
const BRONZE_LIGHT: Color = Color("f0c088")
const BRONZE: Color = Color("c08040")
const BRONZE_DARK: Color = Color("7a4a22")
const LAPIS_LIGHT: Color = Color("6c8ee0")
const LAPIS: Color = Color("2c4a9a")
const LAPIS_DARK: Color = Color("1a2a60")
const CARNELIAN_LIGHT: Color = Color("f0906a")
const CARNELIAN: Color = Color("c04a30")
const BASALT_LIGHT: Color = Color("6a6a72")
const BASALT: Color = Color("2a2a30")


## One worn sprite: its image, pivot and how it is worn.
class Piece:
	var image: Image
	var pivot: Vector2
	var points: Array[StringName]
	var layer: WornArt.Layer
	var follows_angle: bool

	func _init(p_image: Image, p_pivot: Vector2, p_points: Array[StringName], p_layer: WornArt.Layer,
			p_follows: bool) -> void:
		image = p_image
		pivot = p_pivot
		points = p_points
		layer = p_layer
		follows_angle = p_follows


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var pieces: Dictionary[StringName, Piece] = {
		&"short_sword": Piece.new(_short_sword(), Vector2(6, 4), [&"hand_r"], WornArt.Layer.FRONT, true),
		&"sappara": Piece.new(_sappara(), Vector2(5, 4), [&"hand_r"], WornArt.Layer.FRONT, true),
		&"bronze_mace": Piece.new(_mace(), Vector2(5, 6), [&"hand_r"], WornArt.Layer.FRONT, true),
		&"lapis_shield": Piece.new(_shield(), Vector2(11, 12), [&"hand_l"], WornArt.Layer.BEHIND, false),
		&"scribes_circlet": Piece.new(_circlet(), Vector2(7, 2), [&"head"], WornArt.Layer.FRONT, false),
		&"seal_of_shamash": Piece.new(_cylinder_seal(CARNELIAN_LIGHT, CARNELIAN), Vector2(3, 1), [&"seal"], WornArt.Layer.FRONT, false),
		&"seal_of_nergal": Piece.new(_cylinder_seal(BASALT_LIGHT, BASALT), Vector2(3, 1), [&"seal"], WornArt.Layer.FRONT, false),
		&"gazelle_anklet": Piece.new(_anklet(), Vector2(4, 3), [&"ankle_f", &"ankle_b"], WornArt.Layer.FRONT, false),
		&"scythe_of_ninurta": Piece.new(_scythe(), Vector2(15, 12), [&"hand_r"], WornArt.Layer.FRONT, true),
	}
	var needs_import: bool = false
	for id: StringName in pieces:
		var png: String = OUT.path_join(String(id) + ".png")
		var bytes: PackedByteArray = pieces[id].image.save_png_to_buffer()
		var existing: PackedByteArray = FileAccess.get_file_as_bytes(png) if FileAccess.file_exists(png) else PackedByteArray()
		if existing != bytes:
			pieces[id].image.save_png(ProjectSettings.globalize_path(png))
			needs_import = true
		if not ResourceLoader.exists(png):
			needs_import = true
	if needs_import:
		print("build_worn_art: wrote PNGs to %s. Run --import, then this script again." % OUT)
		quit(0)
		return
	var ok: bool = true
	for id: StringName in pieces:
		ok = _link(id, pieces[id]) and ok
	ok = _set_dye(&"masons_mail", &"plates", [Color("4a2a14"), Color("9a5a28"), Color("e0a060")]) and ok
	ok = _set_dye(&"crimson_mantle", &"lining", [Color("380611"), Color("8a1428"), Color("ef6a6a")]) and ok
	print("build_worn_art: %s" % ("done" if ok else "FAILED"))
	quit(0 if ok else 1)


## Saves the WornArt for [param id] and sets it on the item (or relic) of that id.
func _link(id: StringName, piece: Piece) -> bool:
	var art: WornArt = WornArt.new()
	art.texture = load(OUT.path_join(String(id) + ".png"))
	art.pivot = piece.pivot
	art.points = piece.points
	art.layer = piece.layer
	art.follows_angle = piece.follows_angle
	var art_path: String = OUT.path_join(String(id) + ".tres")
	if ResourceSaver.save(art, art_path) != OK:
		printerr("build_worn_art: cannot save ", art_path)
		return false
	art = load(art_path)
	var item_path: String = _item_path(id)
	if item_path.is_empty():
		printerr("build_worn_art: no item or relic with id ", id)
		return false
	var item: Resource = load(item_path)
	item.set(&"worn", art)
	return ResourceSaver.save(item, item_path) == OK


func _set_dye(id: StringName, material_name: StringName, ramp: Array[Color]) -> bool:
	var item_path: String = _item_path(id)
	if item_path.is_empty():
		printerr("build_worn_art: no item with id ", id)
		return false
	var item: EquipmentData = load(item_path)
	item.dye_material = material_name
	item.dye_ramp = PackedColorArray(ramp)
	return ResourceSaver.save(item, item_path) == OK


func _item_path(id: StringName) -> String:
	for folder: String in ["weapons", "armor", "seals", "relics"]:
		var path: String = "res://data/%s/%s.tres" % [folder, id]
		if FileAccess.file_exists(path):
			return path
	return ""


# --- Drawing -----------------------------------------------------------------------

func _canvas(width: int, height: int) -> Image:
	var image: Image = Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	return image


func _rect(image: Image, x: int, y: int, w: int, h: int, color: Color) -> void:
	image.fill_rect(Rect2i(x, y, w, h), color)


## Adds a 1 px outline around every opaque pixel (4-neighbourhood).
func _outline(image: Image) -> void:
	var source: Image = image.duplicate() as Image
	for y: int in image.get_height():
		for x: int in image.get_width():
			if source.get_pixel(x, y).a8 > 0:
				continue
			for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var q: Vector2i = Vector2i(x, y) + d
				if q.x >= 0 and q.y >= 0 and q.x < image.get_width() and q.y < image.get_height() \
						and source.get_pixelv(q).a8 > 0:
					image.set_pixel(x, y, OUTLINE)
					break


func _grip(image: Image, x0: int, x1: int, y0: int, y1: int) -> void:
	for y: int in range(y0, y1 + 1):
		for x: int in range(x0, x1 + 1):
			image.set_pixel(x, y, GRIP if (x + y) % 2 == 0 else GRIP_DARK)


## Iron short sword, 34 px blade-to-pommel, pointing right.
func _short_sword() -> Image:
	var image: Image = _canvas(38, 9)
	_rect(image, 1, 3, 2, 3, GOLD)
	image.set_pixel(1, 3, GOLD_LIGHT)
	_grip(image, 3, 8, 3, 5)
	_rect(image, 9, 1, 1, 7, GOLD_LIGHT)
	_rect(image, 10, 1, 1, 7, GOLD_DARK)
	_rect(image, 11, 3, 24, 1, STEEL_LIGHT)
	_rect(image, 11, 4, 24, 1, STEEL)
	_rect(image, 11, 5, 24, 1, STEEL_DARK)
	image.set_pixel(35, 4, STEEL)
	_outline(image)
	return image


## Bronze sickle-sword: straight near the hilt, hooking down toward the tip.
func _sappara() -> Image:
	var image: Image = _canvas(36, 15)
	image.set_pixel(1, 4, GOLD_DARK)
	_grip(image, 2, 7, 3, 5)
	_rect(image, 8, 2, 1, 5, GOLD)
	for x: int in range(9, 34):
		var centre: int = 4 if x <= 18 else 4 + roundi(pow((x - 18) / 15.0, 2.0) * 7.0)
		var tip: bool = x >= 32
		image.set_pixel(x, centre, BRONZE)
		if not tip:
			image.set_pixel(x, centre - 1, BRONZE_LIGHT)
			image.set_pixel(x, centre + 1, BRONZE_DARK)
	_outline(image)
	return image


## Temple guard's flanged bronze mace on a wooden haft.
func _mace() -> Image:
	var image: Image = _canvas(34, 13)
	image.set_pixel(1, 6, BRONZE)
	_rect(image, 2, 5, 21, 1, GRIP)
	_rect(image, 2, 6, 21, 1, GRIP)
	_rect(image, 2, 7, 21, 1, GRIP_DARK)
	_grip(image, 2, 8, 5, 7)
	_rect(image, 23, 3, 8, 7, BRONZE)
	_rect(image, 23, 3, 1, 7, BRONZE_LIGHT)
	_rect(image, 30, 3, 1, 7, BRONZE_DARK)
	for x: int in [24, 27, 30]:
		image.set_pixel(x, 2, BRONZE_LIGHT)
		image.set_pixel(x, 1, BRONZE)
		image.set_pixel(x, 10, BRONZE_DARK)
		image.set_pixel(x, 11, BRONZE_DARK)
	_rect(image, 31, 5, 1, 3, BRONZE_DARK)
	_outline(image)
	return image


## Round lapis shield with a gold rim, boss and rosettes, seen face-on.
func _shield() -> Image:
	var image: Image = _canvas(22, 24)
	var centre: Vector2 = Vector2(10.5, 11.5)
	for y: int in 24:
		for x: int in 22:
			var d: Vector2 = (Vector2(x, y) - centre) / Vector2(9.5, 10.5)
			var r: float = d.length()
			if r > 1.0:
				continue
			if r > 0.82:
				image.set_pixel(x, y, GOLD_LIGHT if d.x + d.y < -0.4 else (GOLD_DARK if d.x + d.y > 0.6 else GOLD))
			else:
				image.set_pixel(x, y, LAPIS_LIGHT if d.x + d.y < -0.7 else (LAPIS_DARK if d.x + d.y > 0.5 else LAPIS))
	_rect(image, 9, 10, 3, 3, GOLD)
	image.set_pixel(9, 10, GOLD_LIGHT)
	for offset: Vector2i in [Vector2i(0, -6), Vector2i(0, 6), Vector2i(-5, 0), Vector2i(5, 0)]:
		image.set_pixel(10 + offset.x, 11 + offset.y, GOLD_LIGHT)
	_outline(image)
	return image


## Thin gold band with a lapis stone at the brow (no outline: it sits on the hair).
func _circlet() -> Image:
	var image: Image = _canvas(15, 4)
	_rect(image, 1, 1, 12, 1, GOLD_LIGHT)
	_rect(image, 1, 2, 12, 1, GOLD_DARK)
	image.set_pixel(13, 1, LAPIS_LIGHT)
	image.set_pixel(13, 2, LAPIS)
	image.set_pixel(14, 1, LAPIS)
	image.set_pixel(14, 2, LAPIS_DARK)
	return image


## Cylinder seal on a gold cord, banded in gold.
func _cylinder_seal(light: Color, dark: Color) -> Image:
	var image: Image = _canvas(7, 11)
	_rect(image, 3, 1, 1, 2, GOLD_DARK)
	_rect(image, 2, 3, 3, 1, GOLD)
	_rect(image, 2, 4, 1, 4, light)
	_rect(image, 3, 4, 2, 4, dark)
	_rect(image, 2, 8, 3, 1, GOLD_DARK)
	_outline(image)
	return image


## War scythe: a long wooden snath (gripped 14 px from the butt) with a bronze collar
## and a crescent steel blade. Drawn pointing right, so the blade hangs toward +y, which
## faces forward when the scythe is held upright.
func _scythe() -> Image:
	var image: Image = _canvas(64, 32)
	image.set_pixel(1, 11, BRONZE_LIGHT)
	image.set_pixel(1, 12, BRONZE_DARK)
	_rect(image, 2, 11, 56, 1, WOOD_LIGHT)
	_rect(image, 2, 12, 56, 1, WOOD)
	_grip(image, 10, 20, 11, 12)
	_rect(image, 57, 10, 3, 4, BRONZE)
	image.set_pixel(57, 10, BRONZE_LIGHT)
	var centre: Vector2 = Vector2(44.0, 12.0)
	for y: int in range(10, 32):
		for x: int in range(40, 64):
			var d: Vector2 = Vector2(x + 0.5, y + 0.5) - centre
			var angle: float = rad_to_deg(atan2(d.y, d.x))
			if angle < 4.0 or angle > 84.0:
				continue
			var thickness: float = 3.6 * (1.0 - angle / 95.0) + 0.6
			var r: float = d.length()
			if r <= 17.0 and r >= 17.0 - thickness:
				image.set_pixel(x, y, STEEL_LIGHT if r > 16.0 else (STEEL if r > 14.8 else STEEL_DARK))
	_outline(image)
	return image


## Gold anklet with a little gazelle-horn charm.
func _anklet() -> Image:
	var image: Image = _canvas(8, 6)
	_rect(image, 1, 2, 6, 1, GOLD_LIGHT)
	_rect(image, 1, 3, 6, 1, GOLD_DARK)
	image.set_pixel(5, 4, GOLD)
	image.set_pixel(6, 5, GOLD_LIGHT)
	return image
