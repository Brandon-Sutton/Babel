extends Node2D
## Scripted check of visible equipment (EQV-002..006, EQV-011): with a full kit on
## (weapon, shield, circlet, two seals, Mason's Mail, Crimson Mantle and the Gazelle
## Anklet), every piece is drawn at its attach point in every frame of every animation,
## the hand point sits on the fist in the art, facing left mirrors everything, swapping
## the weapon swaps the sprite, swings show the smear in the weapon's colour, and Mason's
## Mail turns the steel plates bronze in the rendered frame. Then the two-handed Scythe
## of Ninurta (INV-015) takes the shield off and keeps its arc and grip through the
## reap, and every weapon type (EQV-017) plays its own set for every move.
## Logs "VISUAL PASS/FAIL". Needs a real window: run it via tools/capture.sh (about 2200 frames).

const Greybox := preload("res://tools/builders/build_greybox_tileset.gd")
const TILE_SET: TileSet = preload("res://assets/tilesets/greybox/greybox_tileset.tres")
const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")
const FLOOR_Y: float = 320.0
## One weapon of each type (EQV-017).
const WEAPON_TYPES: Array[StringName] = [
	&"short_sword", &"sappara", &"bronze_mace", &"lion_greatsword", &"scythe_of_ninurta",
]
const KIT: Dictionary[StringName, StringName] = {
	&"left_hand": &"lapis_shield", &"head": &"scribes_circlet",
	&"seal_1": &"seal_of_shamash", &"seal_2": &"seal_of_nergal",
}

var _player: Player
var _arc_seen: bool = false
var _always_in_hand: bool = true
var _rig: EquipmentRig
var _sheet: Image
var _layout: Dictionary


func _ready() -> void:
	Game.reset()
	for slot: StringName in KIT:
		Game.inventory.add(KIT[slot])
		Game.equip(slot, KIT[slot])
	Game.grant_ability(&"double_jump")
	var floor_layer: TileMapLayer = TileMapLayer.new()
	floor_layer.tile_set = TILE_SET
	add_child(floor_layer)
	for x: int in range(-20, 60):
		for y: int in range(20, 23):
			floor_layer.set_cell(Vector2i(x, y), 0, Greybox.SOLID)
	_player = PLAYER_SCENE.instantiate() as Player
	add_child(_player)
	_player.respawn_at(Vector2(200, FLOOR_Y))
	_rig = _player.equipment_rig
	_sheet = Image.load_from_file(ProjectSettings.globalize_path("res://assets/sprites/player/hero/hero.png"))
	_sheet.convert(Image.FORMAT_RGBA8)
	_layout = JSON.parse_string(FileAccess.get_file_as_string("res://assets/sprites/player/hero/hero.json"))
	_run.call_deferred()


func _run() -> void:
	await _frames(20)
	_check_pieces()
	_check_anchors_in_art()
	await _check_every_frame()
	await _check_mirror()
	await _check_weapon_swap()
	await _check_smear()
	await _check_dye()
	await _showcase()
	await _check_scythe()
	await _check_weapon_types()
	print("equipment_test: done")


## Every equipped item and the relic has a sprite, and all are visible standing still.
func _check_pieces() -> void:
	var names: PackedStringArray = []
	var visible_count: int = 0
	for child: Node in _rig.get_children():
		var sprite: Sprite2D = child as Sprite2D
		if sprite == null or sprite.name == "Smear":
			continue
		names.append(sprite.texture.resource_path.get_file().get_basename())
		if sprite.visible:
			visible_count += 1
	var expected: PackedStringArray = ["short_sword", "lapis_shield", "scribes_circlet", "seal_of_shamash",
			"seal_of_nergal", "gazelle_anklet", "gazelle_anklet", "builders_plan"]
	var missing: PackedStringArray = []
	for id: String in expected:
		if not names.has(id):
			missing.append(id)
	_report("every item is worn", missing.is_empty() and visible_count == expected.size(),
			"%d sprites (%s), %d visible, missing %s" % [names.size(), ", ".join(names), visible_count, missing])


## In the imported art, each frame's hand point is on the fist (skin within 3 px) and
## the head point is on hair or face.
func _check_anchors_in_art() -> void:
	var cell: Vector2i = Vector2i(int(_layout["cell"][0]), int(_layout["cell"][1]))
	var pivot: Vector2i = Vector2i(int(_layout["pivot"][0]), int(_layout["pivot"][1]))
	var frames: int = 0
	var hand_misses: PackedStringArray = []
	var head_misses: PackedStringArray = []
	var animations: Dictionary = _layout["animations"]
	for anim_name: String in animations:
		var entry: Dictionary = animations[anim_name]
		var anchors: Array = entry["anchors"]
		for col: int in anchors.size():
			var points: Dictionary = anchors[col]
			var origin: Vector2i = Vector2i(col * cell.x, int(entry["row"]) * cell.y) + pivot
			frames += 1
			# A two-handed grip is the midpoint between both fists, so allow a little more.
			var reach: int = 6 if _is_two_handed_set(anim_name) else 3
			if not points.get("smear", false) and not _near(origin, points["hand_r"], reach, _is_skin):
				hand_misses.append("%s %d" % [anim_name, col])
			if not _near(origin, points["head"], 2, _is_opaque):
				head_misses.append("%s %d" % [anim_name, col])
	_report("attach points sit on the art", hand_misses.is_empty() and head_misses.is_empty(),
			"%d frames; hand off the fist: %s; head off the head: %s" % [frames, hand_misses, head_misses])


## Plays every animation and checks each frame: pieces sit exactly on their point.
func _check_every_frame() -> void:
	var checked: int = 0
	var errors: PackedStringArray = []
	for anim_name: String in (_layout["animations"] as Dictionary):
		var entry: Dictionary = _layout["animations"][anim_name]
		for col: int in int(entry["frames"]):
			_player.sprite.frame_coords = Vector2i(col, int(entry["row"]))
			_player.animation_player.pause()
			await _frames(1)
			var points: Dictionary = (entry["anchors"] as Array)[col]
			for child: Node in _rig.get_children():
				var sprite: Sprite2D = child as Sprite2D
				if sprite == null or sprite.name == "Smear" or not sprite.visible:
					continue
				checked += 1
				if not _on_some_point(sprite, points, 1.0):
					errors.append("%s %d %s" % [anim_name, col, sprite.texture.resource_path.get_file()])
	_player.animation_player.play(&"idle")
	_report("pieces follow every frame", checked > 100 and errors.is_empty(),
			"%d piece placements checked, %d off their point %s" % [checked, errors.size(), errors.slice(0, 4)])


## Facing left mirrors the hand point and flips the weapon.
func _check_mirror() -> void:
	_player.face(-1)
	await _frames(3)
	var weapon: Sprite2D = _piece("short_sword")
	var points: Dictionary = _rig._anchors.get(_player.sprite.frame_coords, {})
	var hand: Array = points.get("hand_r", [0, 0, 0])
	var ok: bool = weapon.flip_h and is_equal_approx(weapon.position.x, roundf(-float(hand[0]))) \
			and weapon.rotation_degrees <= 0.0
	_report("facing left mirrors the gear", ok, "weapon x %.0f (hand %.1f), flipped %s, rotation %.0f" % [
			weapon.position.x, float(hand[0]), weapon.flip_h, weapon.rotation_degrees])
	_player.face(1)
	await _frames(3)


## Equipping the Sappara replaces the sword in the hand.
func _check_weapon_swap() -> void:
	Game.inventory.add(&"sappara")
	Game.equip(&"right_hand", &"sappara")
	await _frames(2)
	var ok: bool = _piece("sappara") != null and _piece("short_sword") == null
	_report("swapping the weapon swaps the sprite", ok, "sappara shown=%s, sword gone=%s" % [
			_piece("sappara") != null, _piece("short_sword") == null])
	Game.equip(&"right_hand", &"short_sword")
	await _frames(2)


## During the swing's smear frames the weapon hides and the smear shows in its colour.
func _check_smear() -> void:
	var saw_smear: bool = false
	var weapon_hidden: bool = true
	var tint_ok: bool = true
	Input.action_press(&"attack_right")
	await _frames(1)
	Input.action_release(&"attack_right")
	for i: int in 30:
		await _frames(1)
		var smear: Sprite2D = _rig.get_node(^"Smear") as Sprite2D
		if smear.visible:
			saw_smear = true
			weapon_hidden = weapon_hidden and not _piece("short_sword").visible
			tint_ok = tint_ok and smear.modulate.is_equal_approx(Color(Game.stats.weapon.slash_color, 1.0))
	_report("swing smear in the weapon's colour", saw_smear and weapon_hidden and tint_ok,
			"smear seen=%s, weapon hidden then=%s, tinted=%s" % [saw_smear, weapon_hidden, tint_ok])
	await _frames(20)


## Mason's Mail (bronze plates) vs no body armor: bronze pixels on the rendered body.
func _check_dye() -> void:
	await _frames(5)
	var with_mail: int = await _bronze_pixels()
	Game.equip(&"body", &"")
	await _frames(3)
	var without: int = await _bronze_pixels()
	Game.equip(&"body", &"masons_mail")
	await _frames(3)
	_report("Mason's Mail turns the plates bronze", with_mail > without + 15,
			"bronze pixels on the body: %d with the mail, %d without" % [with_mail, without])


## Walk, jump, crouch-slash and slash with the full kit, for the eyes.
func _showcase() -> void:
	Input.action_press(&"move_right")
	await _frames(50)
	Input.action_release(&"move_right")
	await _press(&"jump")
	await _frames(45)
	Input.action_press(&"move_down")
	await _frames(15)
	await _press(&"attack_right")
	await _frames(30)
	Input.action_release(&"move_down")
	await _frames(10)
	await _press(&"attack_right")
	await _frames(40)


## The scythe takes both hands and brings its own idle, walk and reap.
func _check_scythe() -> void:
	Game.inventory.add(&"scythe_of_ninurta")
	var shields_before: int = Game.inventory.count(&"lapis_shield")
	Game.equip(&"right_hand", &"scythe_of_ninurta")
	await _frames(3)
	var shield_returned: bool = Game.inventory.count(&"lapis_shield") == shields_before + 1
	var shield_off: bool = (not Game.stats.equipped.has(&"left_hand") and shield_returned
			and _piece("lapis_shield") == null and _piece("scythe_of_ninurta") != null)
	_report("the scythe takes both hands", shield_off, "left hand empty=%s, shield back in the bag=%s, scythe drawn=%s" % [
			not Game.stats.equipped.has(&"left_hand"), shield_returned, _piece("scythe_of_ninurta") != null])
	await _play_moves()
	_report("the reap shows its arc and keeps the scythe in hand", _arc_seen and _always_in_hand,
			"arc drawn=%s, scythe visible every frame=%s" % [_arc_seen, _always_in_hand])
	Game.equip(&"right_hand", &"short_sword")
	await _frames(2)
	_report("swapping back changes the stance at once", _player.animation_player.assigned_animation == &"idle",
			"animation after the swap: %s" % _player.animation_player.assigned_animation)


## Every weapon type plays its own set for every move (EQV-017): the sword uses the
## shared set, every other type its "<stance>_<move>" animations.
func _check_weapon_types() -> void:
	var wrong: PackedStringArray = []
	var checked: int = 0
	for id: StringName in WEAPON_TYPES:
		Game.inventory.add(id)
		Game.equip(&"right_hand", id)
		await _frames(3)
		var stance: StringName = (Game.stats.weapon as WeaponData).stance
		var seen: Dictionary[StringName, StringName] = await _play_moves()
		for move: StringName in seen:
			checked += 1
			var expected: StringName = move if stance.is_empty() else StringName("%s_%s" % [stance, move])
			if seen[move] != expected:
				wrong.append("%s %s played %s" % [id, move, seen[move]])
	_report("each weapon type has its own set", checked == WEAPON_TYPES.size() * 7 and wrong.is_empty(),
			"%d weapon moves checked: %s" % [checked, "all match" if wrong.is_empty() else ", ".join(wrong)])
	Game.equip(&"right_hand", &"short_sword")
	await _frames(2)


## Walks, crouches, jumps, falls, back-dashes and attacks with the current weapon and
## returns the animation each move played. Also records whether the procedural arc
## showed and whether the weapon stayed visible through the swing.
func _play_moves() -> Dictionary[StringName, StringName]:
	_player.respawn_at(Vector2(200, FLOOR_Y))
	_player.invulnerable_frames = 0
	_player.face(1)
	await _frames(3)
	var weapon_id: String = String(Game.stats.weapon.id)
	var seen: Dictionary[StringName, StringName] = {&"idle": _player.animation_player.assigned_animation}
	Input.action_press(&"move_right")
	await _frames(20)
	seen[&"walk"] = _player.animation_player.assigned_animation
	Input.action_release(&"move_right")
	await _frames(5)
	Input.action_press(&"move_down")
	await _frames(15)
	seen[&"crouch"] = _player.animation_player.assigned_animation
	Input.action_release(&"move_down")
	await _frames(5)
	# Hold jump for a full jump, then sample the first frame of the fall.
	Input.action_press(&"jump")
	await _frames(6)
	seen[&"jump"] = _player.animation_player.assigned_animation
	for i: int in 60:
		await _frames(1)
		if not _player.is_on_floor() and _player.velocity.y > 60.0:
			break
	await _frames(2)
	seen[&"fall"] = _player.animation_player.assigned_animation
	Input.action_release(&"jump")
	await _frames(40)
	await _press(&"backdash")
	await _frames(3)
	seen[&"backdash"] = _player.animation_player.assigned_animation
	await _frames(30)
	await _press(&"attack_right")
	await _frames(2)
	seen[&"attack"] = _player.animation_player.assigned_animation
	_arc_seen = false
	_always_in_hand = true
	for i: int in 45:
		await _frames(1)
		_arc_seen = _arc_seen or _player.slash_fx._frames_left > 0
		_always_in_hand = _always_in_hand and _piece(weapon_id) != null and _piece(weapon_id).visible
	await _frames(15)
	return seen


## True if [param anim_name] belongs to a two-handed weapon type's set.
func _is_two_handed_set(anim_name: String) -> bool:
	for id: StringName in WEAPON_TYPES:
		var weapon: WeaponData = Game.item(id) as WeaponData
		if weapon.two_handed and anim_name.begins_with(String(weapon.stance) + "_"):
			return true
	return false


func _bronze_pixels() -> int:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var screen: Vector2 = _player.get_global_transform_with_canvas().origin
	var count: int = 0
	for y: int in range(roundi(screen.y) - 70, roundi(screen.y) - 10):
		for x: int in range(roundi(screen.x) - 20, roundi(screen.x) + 20):
			if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
				continue
			var c: Color = image.get_pixel(x, y).linear_to_srgb()
			if c.r > 0.45 and c.r > c.g * 1.25 and c.g > c.b * 1.3:
				count += 1
	return count


func _piece(id: String) -> Sprite2D:
	for child: Node in _rig.get_children():
		var sprite: Sprite2D = child as Sprite2D
		if sprite != null and sprite.texture != null and sprite.texture.resource_path.get_file().get_basename() == id:
			return sprite
	return null


func _on_some_point(sprite: Sprite2D, points: Dictionary, tolerance: float) -> bool:
	var facing: float = -1.0 if _player.sprite.flip_h else 1.0
	for key: String in points:
		var value: Variant = points[key]
		if value is Array:
			var at: Vector2 = Vector2(roundf(float(value[0]) * facing), roundf(float(value[1])))
			if sprite.position.distance_to(at) <= tolerance:
				return true
	return false


func _near(origin: Vector2i, point: Variant, radius: int, test: Callable) -> bool:
	var at: Vector2i = origin + Vector2i(roundi(float(point[0])), roundi(float(point[1])))
	for dy: int in range(-radius, radius + 1):
		for dx: int in range(-radius, radius + 1):
			var p: Vector2i = at + Vector2i(dx, dy)
			if p.x >= 0 and p.y >= 0 and p.x < _sheet.get_width() and p.y < _sheet.get_height() \
					and test.call(_sheet.get_pixelv(p)):
				return true
	return false


func _is_skin(c: Color) -> bool:
	return GuideProp.is_skin(c)


func _is_opaque(c: Color) -> bool:
	return c.a8 > 0


func _press(action: StringName) -> void:
	Input.action_press(action)
	await _frames(1)
	Input.action_release(action)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _report(check: String, ok: bool, detail: String) -> void:
	print("VISUAL %s %s: %s (frame %d)" % ["PASS" if ok else "FAIL", check, detail, Engine.get_process_frames()])
