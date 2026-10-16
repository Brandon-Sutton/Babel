extends Boss
## The Weeping Effigy: the test boss for the boss framework (BOSS-000) and severable
## parts (BOSS-030). A stone saint with a sewn mouth, gold leaf over cracked stone,
## weeping crimson. Painted in code until real bosses have art. Its two arms and its mask
## can be torn off:
##   SLAM   (front arm)  raises the arm and brings it down in front    -> back away
##   SWEEP  (back arm)   swings the arm along the floor                 -> jump it
##   TEARS  (always)     tears fall on Elam from above                  -> keep moving
##   GAZE   (no mask)    the eyes beneath the mask fire bolts at Elam   -> jump or cut them
## Losing an arm ends its attack; losing the mask unlocks the gaze. Phase 2 (half HP)
## plays everything faster and weeps more tears.

## Pattern timings: wind-up, active and recovery frames (before the phase speed-up).
const SLAM: Vector3i = Vector3i(34, 8, 34)
const SWEEP: Vector3i = Vector3i(30, 10, 30)
const TEARS_WINDUP: int = 24
const TEAR_EVERY: int = 10
const GAZE_WINDUP: int = 26
const BOLT_EVERY: int = 8
## Attack boxes in the body's coordinates, facing right (the body mirrors them).
const SLAM_BOX: Rect2 = Rect2(20, -44, 84, 44)
const SWEEP_BOX: Rect2 = Rect2(-10, -18, 150, 18)
const TEAR_OFFSETS: Array[float] = [0.0, -48.0, 48.0, -96.0, 96.0]
const TEAR_HEIGHT: float = 300.0
const BOLT_SPEED: float = 220.0
## The chest crack's path, one step per row.
const CRACK_STEPS: Array[int] = [0, 1, 0, -1, 0, 0, 1, -1]
const CRIMSON: Color = Color("c0263c")
const EMBER: Color = Color("ef6a6a")

const STONE_DARK: Color = Color("3a3446")
const STONE: Color = Color("5a5266")
const STONE_LIGHT: Color = Color("7e7590")
const PALE: Color = Color("b8b0c4")
const PALE_DARK: Color = Color("857c96")
const GOLD: Color = Color("c59c5c")
const GOLD_LIGHT: Color = Color("f4d68a")
const FLESH_DARK: Color = Color("4a0c18")
const FLESH: Color = Color("8a1428")
const FLESH_LIGHT: Color = Color("c0263c")
const BONE: Color = Color("f0e8d0")
const OUTLINE: Color = Color("1a1420")

var _arm_base: Dictionary[StringName, Vector2] = {}
var _tears_left: int = 0
var _tears_total: int = 0
var _bolts_left: int = 0

@onready var _visual: Node2D = %Visual
@onready var _body: Sprite2D = %Body
@onready var _attack: Hitbox = %AttackHitbox
@onready var _attack_shape: CollisionShape2D = %AttackShape


func _ready() -> void:
	super._ready()
	_attack_shape.shape = _attack_shape.shape.duplicate() as Shape2D
	_attack.owner_node = self
	_attack.knockback = 200.0
	_attack.hit_stop_frames = 4
	_body.texture = ImageTexture.create_from_image(_paint_body())
	_body.offset = -Vector2(34, 112)
	parts[&"mask"].set_art(ImageTexture.create_from_image(_paint_mask(false)),
			ImageTexture.create_from_image(_paint_mask(true)), Vector2(13, 30))
	parts[&"arm_front"].set_art(ImageTexture.create_from_image(_paint_arm(false, false)),
			ImageTexture.create_from_image(_paint_arm(false, true)), Vector2(8, 6))
	parts[&"arm_back"].set_art(ImageTexture.create_from_image(_paint_arm(true, false)),
			ImageTexture.create_from_image(_paint_arm(true, true)), Vector2(24, 6))
	for id: StringName in parts:
		_arm_base[id] = parts[id].position


func _behave(delta: float) -> void:
	super._behave(delta)
	var mirror: float = float(facing)
	if _visual.scale.x != mirror:
		_visual.scale.x = mirror
		_visual.reset_physics_interpolation()


# --- Patterns ---------------------------------------------------------------------------

func _start_pattern(id: StringName) -> void:
	match id:
		&"tears":
			_tears_total = TEAR_OFFSETS.size() if phase > 0 else 3
			_tears_left = _tears_total
		&"gaze":
			_bolts_left = 3


func _update_pattern(id: StringName, frame: int) -> bool:
	match id:
		&"slam":
			return _swing(frame, SLAM, &"arm_front", SLAM_BOX, Vector2(0, -26), Vector2(0, 4), 6)
		&"sweep":
			return _swing(frame, SWEEP, &"arm_back", SWEEP_BOX, Vector2(-12, -6), Vector2(40, 22), 4)
		&"tears":
			return _weep(frame)
		&"gaze":
			return _gaze(frame)
	return true


## A melee swing with arm [param arm]: it draws back to [param raised] during the wind-up
## (flashing gold), strikes through [param box] at [param struck], then recovers.
func _swing(frame: int, timing: Vector3i, arm: StringName, box: Rect2, raised: Vector2, struck: Vector2,
		power_bonus: int) -> bool:
	var windup: int = scaled(timing.x)
	var active: int = timing.y
	var recover: int = scaled(timing.z)
	var part: BossPart = parts[arm]
	if frame <= windup:
		part.position = _arm_base[arm] + raised * (float(frame) / windup)
		set_flash(0.25 + 0.35 * float(frame % 8 < 4), TELEGRAPH)
	elif frame <= windup + active:
		if frame == windup + 1:
			set_flash(0.0)
			part.position = _arm_base[arm] + struck
			_set_attack(box, data.attack + power_bonus, true)
			GameCamera.shake(get_tree(), 3.0, 10)
	elif frame <= windup + active + recover:
		_set_attack(box, 0, false)
		part.position = (_arm_base[arm] + struck).lerp(_arm_base[arm], float(frame - windup - active) / recover)
	else:
		part.position = _arm_base[arm]
		return true
	return false


## Tears fall on Elam from high above, one every TEAR_EVERY frames.
func _weep(frame: int) -> bool:
	var windup: int = scaled(TEARS_WINDUP)
	if frame <= windup:
		return false
	var step: int = frame - windup
	if _tears_left > 0 and step % TEAR_EVERY == 1:
		var player: Player = target()
		if player != null:
			var offset: float = TEAR_OFFSETS[_tears_total - _tears_left]
			var at: Vector2 = Vector2(player.global_position.x + offset, global_position.y - TEAR_HEIGHT)
			EnemyShot.launch(get_parent(), at, &"tear", Vector2(0, 60), data.attack, 500.0, CRIMSON)
		_tears_left -= 1
	return _tears_left <= 0 and step > TEAR_EVERY * 2


## The eyes beneath the mask fire bolts at Elam.
func _gaze(frame: int) -> bool:
	var windup: int = scaled(GAZE_WINDUP)
	if frame <= windup:
		set_flash(0.2 + 0.3 * float(frame % 6 < 3), EMBER)
		return false
	if frame == windup + 1:
		set_flash(0.0)
	var step: int = frame - windup
	if _bolts_left > 0 and step % BOLT_EVERY == 1:
		var player: Player = target()
		var from: Vector2 = parts[&"mask"].global_position + Vector2(0, -16)
		if player != null:
			var aim: Vector2 = (player.global_position + Vector2(0, -40) - from).normalized()
			EnemyShot.launch(get_parent(), from, &"bolt", aim * BOLT_SPEED, data.attack + 2, 0.0, Color("f0eef8"))
		_bolts_left -= 1
	return _bolts_left <= 0 and step > BOLT_EVERY * 2


func _cancel_pattern(_id: StringName) -> void:
	_set_attack(Rect2(), 0, false)
	set_flash(0.0)
	_tears_left = 0
	_bolts_left = 0
	for id: StringName in parts:
		if not parts[id].is_severed():
			parts[id].position = _arm_base[id]


func _set_attack(box: Rect2, power: int, on: bool) -> void:
	if on:
		(_attack_shape.shape as RectangleShape2D).size = box.size
		_attack_shape.position = box.get_center()
		_attack.attack = power
	_attack.active = on


func _draw() -> void:
	# The reach of a swing is drawn as a crimson streak while it is live.
	if current == null or not _attack.active:
		return
	var box: Rect2 = SLAM_BOX if current.id == &"slam" else SWEEP_BOX
	var mirrored: Rect2 = box if facing > 0 else Rect2(-box.end.x, box.position.y, box.size.x, box.size.y)
	draw_rect(mirrored, Color(CRIMSON, 0.35))
	draw_rect(Rect2(mirrored.position.x, mirrored.end.y - 2, mirrored.size.x, 2), Color(EMBER, 0.7))


# --- Art (drawn in code until the real bosses have PixelLab art) --------------------------

func _canvas(width: int, height: int) -> Image:
	var image: Image = Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	return image


func _ellipse(image: Image, centre: Vector2, radius: Vector2, color: Color) -> void:
	for y: int in image.get_height():
		for x: int in image.get_width():
			var d: Vector2 = (Vector2(x, y) + Vector2(0.5, 0.5) - centre) / radius
			if d.length_squared() <= 1.0:
				image.set_pixel(x, y, color)


func _outline(image: Image) -> void:
	var source: Image = image.duplicate() as Image
	for y: int in image.get_height():
		for x: int in image.get_width():
			if source.get_pixel(x, y).a8 > 0:
				continue
			for step: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var q: Vector2i = Vector2i(x, y) + step
				if q.x >= 0 and q.y >= 0 and q.x < image.get_width() and q.y < image.get_height() \
						and source.get_pixelv(q).a8 > 0:
					image.set_pixel(x, y, OUTLINE)
					break


## A robed stone saint, gold at the collar and hem, a crack glowing crimson down the chest.
func _paint_body() -> Image:
	var image: Image = _canvas(68, 112)
	for y: int in range(6, 112):
		var half: int = roundi(lerpf(18.0, 32.0, (y - 6) / 105.0))
		for x: int in range(34 - half, 34 + half):
			var color: Color = STONE
			if x < 34 - half + 3:
				color = STONE_LIGHT
			elif x > 34 + half - 4:
				color = STONE_DARK
			elif y > 30 and (x - 34 + 60) % 9 == 0:
				color = STONE_DARK
			image.set_pixel(x, y, color)
	image.fill_rect(Rect2i(30, 0, 9, 7), STONE)
	image.fill_rect(Rect2i(16, 6, 36, 2), GOLD)
	image.fill_rect(Rect2i(3, 103, 62, 2), GOLD)
	image.fill_rect(Rect2i(3, 103, 62, 1), GOLD_LIGHT)
	var x: int = 36
	for y: int in range(18, 72):
		x += CRACK_STEPS[y % 8]
		image.set_pixel(x, y, CRIMSON)
		if y % 3 == 0:
			image.set_pixel(x + 1, y, EMBER)
	_outline(image)
	return image


## The mask: a pale face with closed eyes, a sewn mouth, crimson tears and a gilded band
## crowned with nails. Beneath it: raw flesh and too many eyes.
func _paint_mask(beneath: bool) -> Image:
	var image: Image = _canvas(26, 30)
	if beneath:
		_ellipse(image, Vector2(13, 16), Vector2(10, 13), FLESH)
		_ellipse(image, Vector2(12, 15), Vector2(7, 9), FLESH_LIGHT)
		for eye: Vector2i in [Vector2i(9, 9), Vector2i(16, 10), Vector2i(12, 15), Vector2i(7, 19), Vector2i(17, 18),
				Vector2i(11, 23), Vector2i(15, 24)]:
			image.fill_rect(Rect2i(eye.x - 1, eye.y, 3, 2), BONE)
			image.set_pixel(eye.x, eye.y, FLESH_DARK)
		for y: int in range(26, 30):
			image.set_pixel(12 + y % 2, y, FLESH)
	else:
		_ellipse(image, Vector2(13, 16), Vector2(10, 13), PALE)
		_ellipse(image, Vector2(15, 18), Vector2(8, 10), PALE_DARK)
		_ellipse(image, Vector2(12, 15), Vector2(8, 10), PALE)
		image.fill_rect(Rect2i(4, 6, 18, 2), GOLD)
		for x: int in range(5, 22, 4):
			image.fill_rect(Rect2i(x, 2, 1, 4), STONE_DARK)
		for eye_x: int in [8, 15]:
			image.fill_rect(Rect2i(eye_x, 12, 3, 1), STONE_DARK)
			for y: int in range(13, 27):
				image.set_pixel(eye_x + 1, y, CRIMSON)
		image.fill_rect(Rect2i(10, 21, 7, 1), STONE_DARK)
		for x: int in range(10, 17, 2):
			image.fill_rect(Rect2i(x, 20, 1, 3), OUTLINE)
	_outline(image)
	return image


## A pale marble arm hanging from the shoulder (the canvas pivot) out to a great fist,
## gold at the wrist, so it stands out from the grey robe. [param back] mirrors it to hang
## behind. Beneath: a torn stump of bone and flesh at the shoulder, dripping.
func _paint_arm(back: bool, beneath: bool) -> Image:
	var image: Image = _canvas(32, 84)
	var shoulder: Vector2 = Vector2(24, 6) if back else Vector2(8, 6)
	if beneath:
		_ellipse(image, shoulder + Vector2(0, 2), Vector2(6, 6), FLESH)
		_ellipse(image, shoulder + Vector2(0, 2), Vector2(4, 4), FLESH_LIGHT)
		image.fill_rect(Rect2i(int(shoulder.x) - 1, int(shoulder.y), 3, 3), BONE)
		for y: int in range(int(shoulder.y) + 8, int(shoulder.y) + 18):
			if y % 3 != 0:
				image.set_pixel(int(shoulder.x) - 2 + (y % 2) * 3, y, FLESH)
		_outline(image)
		return image
	var direction: float = -1.0 if back else 1.0
	var joints: Array[Vector2] = [shoulder, shoulder + Vector2(7 * direction, 34), shoulder + Vector2(14 * direction, 60)]
	for i: int in 2:
		var from: Vector2 = joints[i]
		var to: Vector2 = joints[i + 1]
		for step: int in 40:
			var at: Vector2 = from.lerp(to, step / 39.0)
			_ellipse_at(image, at, 4.0 - i * 0.5, PALE_DARK if back else PALE)
			image.set_pixel(int(at.x - 3 * direction), int(at.y), PALE if back else Color("e4dcec"))
			image.set_pixel(int(at.x + 3 * direction), int(at.y), PALE_DARK if not back else STONE)
	var wrist: Vector2 = joints[2]
	image.fill_rect(Rect2i(int(wrist.x) - 4, int(wrist.y) - 1, 9, 2), GOLD)
	var fist: Rect2i = Rect2i(int(wrist.x) - 7, int(wrist.y) + 2, 14, 16)
	image.fill_rect(fist, PALE_DARK if back else PALE)
	image.fill_rect(Rect2i(fist.position.x, fist.position.y, 2, fist.size.y), PALE if back else Color("e4dcec"))
	image.fill_rect(Rect2i(fist.end.x - 2, fist.position.y, 2, fist.size.y), STONE if back else PALE_DARK)
	for y: int in range(fist.position.y + 4, fist.end.y - 2, 4):
		image.fill_rect(Rect2i(fist.position.x + 3, y, fist.size.x - 6, 1), STONE)
	_outline(image)
	return image


func _ellipse_at(image: Image, centre: Vector2, radius: float, color: Color) -> void:
	var r: int = ceili(radius)
	for y: int in range(int(centre.y) - r, int(centre.y) + r + 1):
		for x: int in range(int(centre.x) - r, int(centre.x) + r + 1):
			if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height() \
					and Vector2(x + 0.5, y + 0.5).distance_to(centre) <= radius:
				image.set_pixel(x, y, color)
