class_name EquipmentRig
extends Node2D
## EQV-005: shows everything Elam has equipped or carries, every frame (GDD §6.7).
##
## Rigid items (weapons, shield, helm, seals, relics) are sprites placed on the attach
## points the importer measured for the body's current frame (EQV-002/003). Body armor
## and mantles recolor the body through equipment_dye.gdshader (EQV-006). A weapon swing
## shows the frame's smear mask tinted with the weapon's slash colour instead of the
## weapon itself. Rebuilt whenever the equipment or the owned relics change.

## Where the two seal slots hang a seal.
const SEAL_POINTS: Dictionary[StringName, StringName] = {&"seal_1": &"chest", &"seal_2": &"belt"}
## Hand items turn in steps of this many degrees, so rotated pixel art stays steady.
const ANGLE_STEP: float = 5.0
const HAND_POINTS: Array[StringName] = [&"hand_r", &"hand_l"]


## One sprite of one worn item.
class Piece:
	var sprite: Sprite2D
	var art: WornArt
	var point: StringName
	var is_weapon: bool

	func _init(p_sprite: Sprite2D, p_art: WornArt, p_point: StringName, p_is_weapon: bool) -> void:
		sprite = p_sprite
		art = p_art
		point = p_point
		is_weapon = p_is_weapon


## Attach points per body frame: frame_coords -> {point name: [x, y(, angle)], "smear": bool}.
var _anchors: Dictionary[Vector2i, Dictionary] = {}
## Frames whose animation carries hand points (guide-prop animations).
var _has_hands: Dictionary[Vector2i, bool] = {}
## Animations whose art includes a swing smear.
var _smeared: Dictionary[StringName, bool] = {}
var _body: Sprite2D
var _smear: Sprite2D
var _dye: ShaderMaterial
var _pieces: Array[Piece] = []
var _weapon: WeaponData
var _signature: String = "-"


func _ready() -> void:
	# After the AnimationPlayer has set this frame's frame_coords.
	process_priority = 100


## Called by the player once its sprite sheet is loaded. [param layout] is the parsed
## <slug>.json; [param smear_texture] may be null.
func setup(body: Sprite2D, layout: Dictionary, smear_texture: Texture2D) -> void:
	_body = body
	_anchors.clear()
	_has_hands.clear()
	_smeared.clear()
	var animations: Dictionary = layout.get("animations", {})
	for anim_name: String in animations:
		var entry: Dictionary = animations[anim_name]
		var row: int = int(entry["row"])
		var frames: Array = entry.get("anchors", [])
		for col: int in frames.size():
			_anchors[Vector2i(col, row)] = frames[col]
			_has_hands[Vector2i(col, row)] = entry.get("hands", false)
			if (frames[col] as Dictionary).get("smear", false):
				_smeared[StringName(anim_name)] = true
	_dye = ShaderMaterial.new()
	_dye.shader = preload("res://assets/shaders/equipment_dye.gdshader")
	_body.material = _dye
	if smear_texture != null:
		_smear = Sprite2D.new()
		_smear.name = "Smear"
		_smear.texture = smear_texture
		_smear.centered = false
		_smear.hframes = body.hframes
		_smear.vframes = body.vframes
		_smear.offset = body.offset
		_smear.z_index = 2
		_smear.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(_smear)
	_signature = "-"


## True if [param animation]'s art has its own swing smear. Swings without one get the
## procedural arc (SlashFX) in the weapon's colour instead.
func has_smear(animation: StringName) -> bool:
	return _smeared.has(animation)


func _process(_delta: float) -> void:
	if _body == null:
		return
	var signature: String = _current_signature()
	if signature != _signature:
		_signature = signature
		_rebuild()
	_update()


## Every equipped item and owned relic, as one string, to notice changes cheaply.
func _current_signature() -> String:
	var parts: PackedStringArray = []
	for slot: StringName in PlayerStats.SLOTS:
		var item: EquipmentData = Game.stats.equipped.get(slot)
		parts.append(String(item.id) if item != null else "")
	for ability: StringName in Game.abilities:
		if Game.abilities[ability]:
			parts.append(String(ability))
	return ",".join(parts)


func _rebuild() -> void:
	for piece: Piece in _pieces:
		piece.sprite.queue_free()
	_pieces.clear()
	_weapon = Game.stats.weapon
	for slot: StringName in PlayerStats.SLOTS:
		var item: EquipmentData = Game.stats.equipped.get(slot)
		if item != null and item.worn != null:
			_add(item.worn, slot, item is WeaponData)
	for id: StringName in Db.ids():
		var relic: RelicData = Db.get_entry(id) as RelicData
		if relic != null and relic.worn != null and Game.has_ability(relic.ability):
			_add(relic.worn, &"", false)
	_apply_dyes()


func _add(art: WornArt, slot: StringName, is_weapon: bool) -> void:
	for point: StringName in art.points:
		var resolved: StringName = SEAL_POINTS.get(slot, &"belt") if point == &"seal" else point
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = art.texture
		sprite.centered = false
		sprite.z_index = -1 if art.layer == WornArt.Layer.BEHIND else 1
		# Placed every rendered frame from the body's frame: interpolating would draw a
		# new piece at the feet for one frame.
		sprite.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(sprite)
		_pieces.append(Piece.new(sprite, art, resolved, is_weapon))


func _apply_dyes() -> void:
	_dye.set_shader_parameter(&"dye_plates", false)
	_dye.set_shader_parameter(&"dye_lining", false)
	for item: EquipmentData in Game.stats.equipped.values():
		if item.dye_material.is_empty() or item.dye_ramp.size() < 3:
			continue
		var prefix: String = String(item.dye_material)
		_dye.set_shader_parameter(StringName("dye_" + prefix), true)
		for i: int in 3:
			var c: Color = item.dye_ramp[i]
			_dye.set_shader_parameter(StringName(prefix + ["_dark", "_mid", "_light"][i]), Vector3(c.r, c.g, c.b))


func _update() -> void:
	var coords: Vector2i = _body.frame_coords
	var points: Dictionary = _anchors.get(coords, {})
	var hands: bool = _has_hands.get(coords, false)
	var smear_frame: bool = points.get("smear", false)
	var facing: float = -1.0 if _body.flip_h else 1.0
	if points.has("neck"):
		_dye.set_shader_parameter(&"neck_y", float((points["neck"] as Array)[1]))
	for piece: Piece in _pieces:
		var visible_here: bool = points.has(String(piece.point)) and _body.visible
		if piece.point in HAND_POINTS:
			visible_here = visible_here and hands and not (piece.is_weapon and smear_frame)
		piece.sprite.visible = visible_here
		if not visible_here:
			continue
		var at: Array = points[String(piece.point)]
		var sprite: Sprite2D = piece.sprite
		var size: Vector2 = sprite.texture.get_size()
		sprite.flip_h = facing < 0.0
		sprite.offset = -Vector2(size.x - 1.0 - piece.art.pivot.x if facing < 0.0 else piece.art.pivot.x, piece.art.pivot.y)
		sprite.position = Vector2(roundf(float(at[0]) * facing), roundf(float(at[1])))
		var angle: float = 0.0
		if piece.art.follows_angle and at.size() > 2:
			angle = snappedf(float(at[2]) + piece.art.angle_offset, ANGLE_STEP)
		sprite.rotation_degrees = angle * facing
		sprite.modulate = _body.modulate
	if _smear != null:
		_smear.visible = smear_frame and hands and _weapon != null and _body.visible
		_smear.frame_coords = coords
		_smear.flip_h = _body.flip_h
		if _weapon != null:
			_smear.modulate = Color(_weapon.slash_color, _body.modulate.a)
