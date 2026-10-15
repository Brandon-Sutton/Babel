extends Node2D
## Scripted check of breakable tiles and secret areas (WLD-006) with the real player in
## a one-screen room: a hidden wall looks exactly like the wall around it, the sword
## cracks it and the third hit crumbles it, the secret room beyond stays off camera until
## Elam walks in and the camera pans back when he leaves, a crouching strike breaks a
## hidden floor and falling in shows the cellar, Sling Stones break a cracked brick
## block, and broken tiles stay broken when the room is rebuilt.
## Logs "VISUAL PASS/FAIL". Needs a real window: run it via tools/capture.sh (about
## 1100 frames).

const Greybox := preload("res://tools/builders/build_greybox_tileset.gd")
const WindowSettle := preload("res://tests/visual/window_settle.gd")
const TILE_SET: TileSet = preload("res://assets/tilesets/greybox/greybox_tileset.tres")
const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")
const TILE: int = 16
const FLOOR_ROW: int = 20
const FLOOR_Y: float = FLOOR_ROW * TILE
const HIDDEN_WALL: Rect2i = Rect2i(38, 14, 2, 6)
const HIDDEN_FLOOR: Rect2i = Rect2i(10, 20, 3, 3)
const CRACKED_BLOCK: Rect2i = Rect2i(24, 17, 2, 3)
const EAST_ROOM: Rect2i = Rect2i(40, 10, 14, 10)
const CELLAR: Rect2i = Rect2i(8, 23, 7, 7)

## Camera bounds of this test room: exactly one screen.
var bounds: Rect2 = Rect2(0, 0, 640, 360)
var _player: Player
var _solid: TileMapLayer
var _east: SecretArea
var _cellar: SecretArea
var _found: Array[StringName] = []


func _ready() -> void:
	Game.reset()
	add_to_group(&"room")
	var back: TileMapLayer = _layer("BackWall", -5)
	_fill(back, Rect2i(0, 0, 56, 32), Greybox.BACK_WALL)
	_solid = _build_solid()
	var platforms: TileMapLayer = _layer("Platforms", 0)
	_fill(platforms, Rect2i(9, 26, 5, 1), Greybox.PLATFORM)
	_east = _secret("EastRoom", EAST_ROOM, Rect2(Vector2(56 * TILE - 640, 0), Vector2(640, 360)))
	_cellar = _secret("Cellar", CELLAR, Rect2(Vector2(0, 32 * TILE - 360), Vector2(640, 360)))
	Events.secret_found.connect(func(key: StringName) -> void: _found.append(key))
	_player = PLAYER_SCENE.instantiate() as Player
	add_child(_player)
	_player.god_mode = true
	_run.call_deferred()


func _run() -> void:
	# A focus change while the window opens releases every held action.
	await WindowSettle.settle(self)
	_place(Vector2(300, FLOOR_Y))
	await _frames(10)
	await _check_hidden_looks_solid()
	await _check_break_wall()
	await _check_enter_east()
	await _check_floor()
	await _check_relic_arm_block()
	await _check_reload()
	print("secrets_test: done")


## The hidden wall's pixels match the plain wall's (nothing gives it away).
func _check_hidden_looks_solid() -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var same: bool = true
	for y: int in TILE:
		for x: int in TILE:
			var hidden: Color = image.get_pixel(HIDDEN_WALL.position.x * TILE + x, 16 * TILE + y)
			var plain: Color = image.get_pixel(TILE + x, 16 * TILE + y)
			same = same and hidden.is_equal_approx(plain)
	var offscreen: bool = _player.camera.limit_right == int(bounds.end.x)
	_report("a hidden wall looks like the wall", same and offscreen,
			"pixels identical=%s, camera stops at the room's edge=%s" % [same, offscreen])


## Three sword strikes: the first two crack it, the third crumbles it.
func _check_break_wall() -> void:
	_place(Vector2(HIDDEN_WALL.position.x * TILE - 24, FLOOR_Y))
	await _frames(6)
	var cell: Vector2i = HIDDEN_WALL.position + Vector2i(0, 4)
	var left: PackedInt32Array = []
	for i: int in Greybox.HIDDEN_HITS:
		await _press(&"attack_right")
		await _frames(30)
		left.append(_breakables().hits_left(cell) if _solid.get_cell_source_id(cell) != -1 else 0)
	var gone: bool = _cells_gone(HIDDEN_WALL)
	var rubble: int = _count(Rubble)
	var flag: StringName = WorldKeys.key(_solid, "Solid@%d,%d" % [HIDDEN_WALL.position.x, HIDDEN_WALL.position.y])
	_report("the sword breaks a hidden wall in 3 hits", left == PackedInt32Array([2, 1, 0]) and gone
			and Game.is_flag(flag), "hits left after each strike %s, wall gone=%s, rubble pieces alive %d, flag=%s"
			% [left, gone, rubble, Game.is_flag(flag)])


## Through the gap: the camera pans to the secret room; back out, it pans back.
func _check_enter_east() -> void:
	Input.action_press(&"move_right")
	await _frames(50)
	Input.action_release(&"move_right")
	await _frames(40)
	var view: Rect2 = _east.global_view()
	var inside_limits: bool = _player.camera.limit_left == int(view.position.x) \
			and _player.camera.limit_right == int(view.end.x)
	var found: bool = _found.has(_east.flag()) and Game.is_flag(_east.flag())
	var in_room: bool = _player.global_position.x > EAST_ROOM.position.x * TILE
	await _frames(30)
	Input.action_press(&"move_left")
	await _frames(45)
	Input.action_release(&"move_left")
	await _frames(40)
	var back_limits: bool = _player.camera.limit_left == 0 and _player.camera.limit_right == int(bounds.end.x)
	_report("the secret room shows only once entered", in_room and found and inside_limits and back_limits,
			"in the room=%s, found=%s, camera on the room=%s, back to the bounds=%s"
			% [in_room, found, inside_limits, back_limits])


## A crouching strike breaks the hidden floor; dropping in pans the camera down.
func _check_floor() -> void:
	_place(Vector2(HIDDEN_FLOOR.position.x * TILE - 14, FLOOR_Y))
	await _frames(6)
	Input.action_press(&"move_down")
	await _frames(4)
	for i: int in Greybox.HIDDEN_HITS:
		await _press(&"attack_right")
		await _frames(30)
	Input.action_release(&"move_down")
	var gone: bool = _cells_gone(HIDDEN_FLOOR)
	Input.action_press(&"move_right")
	await _frames(10)
	Input.action_release(&"move_right")
	await _frames(70)
	var view: Rect2 = _cellar.global_view()
	var fell: bool = _player.global_position.y > CELLAR.position.y * TILE
	var limits: bool = _player.camera.limit_bottom == int(view.end.y)
	_report("a crouching strike breaks a hidden floor into the cellar", gone and fell and limits
			and _found.has(_cellar.flag()), "floor gone=%s, fell in=%s (y %.0f), camera shows the cellar=%s, found=%s"
			% [gone, fell, _player.global_position.y, limits, _found.has(_cellar.flag())])


## Sling Stones break the cracked brick (2 hits); enemies can't (their hitboxes don't
## mask the breakable layer).
func _check_relic_arm_block() -> void:
	_place(Vector2(CRACKED_BLOCK.position.x * TILE - 120, FLOOR_Y))
	await _frames(40)
	Game.stats.embers = 10
	for i: int in Greybox.BRICK_HITS:
		await _press(&"relic_arm")
		await _frames(30)
	var gone: bool = _cells_gone(CRACKED_BLOCK)
	_report("Sling Stones break a cracked brick block", gone and Game.stats.embers == 10 - Greybox.BRICK_HITS,
			"block gone=%s, embers 10 -> %d" % [gone, Game.stats.embers])
	await _frames(30)


## Rebuilding the room: broken tiles stay broken, the secrets stay found.
func _check_reload() -> void:
	_solid.free()
	_solid = _build_solid()
	await _frames(3)
	var gone: bool = _cells_gone(HIDDEN_WALL) and _cells_gone(HIDDEN_FLOOR) and _cells_gone(CRACKED_BLOCK)
	var walls_back: bool = _solid.get_cell_source_id(Vector2i(0, 15)) == 0
	var east_found: bool = Game.is_flag(_east.flag())
	_report("broken tiles stay broken on reload", gone and walls_back and east_found and _breakables().group_count() == 0,
			"breakables gone=%s, plain walls back=%s, groups left %d" % [gone, walls_back, _breakables().group_count()])
	# For the eye: the east room, opened.
	_place(Vector2(46 * TILE, FLOOR_Y))
	await _frames(60)


# --- Building -----------------------------------------------------------------------

func _build_solid() -> TileMapLayer:
	var solid: TileMapLayer = _layer("Solid", 0)
	_fill(solid, Rect2i(0, FLOOR_ROW, 40, 3), Greybox.SOLID)
	_fill(solid, Rect2i(0, 0, 2, FLOOR_ROW), Greybox.SOLID)
	_fill(solid, Rect2i(38, 0, 2, FLOOR_ROW), Greybox.SOLID)
	_fill(solid, HIDDEN_WALL, Greybox.SOLID, Greybox.HIDDEN_BREAKABLE_ALT)
	_fill(solid, HIDDEN_FLOOR, Greybox.SOLID, Greybox.HIDDEN_BREAKABLE_ALT)
	_fill(solid, CRACKED_BLOCK, Greybox.BREAKABLE)
	# East room beyond the right wall.
	_fill(solid, Rect2i(40, 0, 16, 10), Greybox.SOLID)
	_fill(solid, Rect2i(40, FLOOR_ROW, 16, 3), Greybox.SOLID)
	_fill(solid, Rect2i(54, 10, 2, 10), Greybox.SOLID)
	# Cellar under the floor.
	_fill(solid, Rect2i(6, 23, 2, 7), Greybox.SOLID)
	_fill(solid, Rect2i(15, 23, 2, 7), Greybox.SOLID)
	_fill(solid, Rect2i(6, 30, 11, 2), Greybox.SOLID)
	var breakables: BreakableTiles = BreakableTiles.new()
	breakables.name = "Breakables"
	solid.add_child(breakables)
	return solid


func _layer(layer_name: String, z: int) -> TileMapLayer:
	var layer: TileMapLayer = TileMapLayer.new()
	layer.name = layer_name
	layer.tile_set = TILE_SET
	layer.z_index = z
	add_child(layer)
	return layer


func _secret(secret_name: String, interior: Rect2i, view: Rect2) -> SecretArea:
	var secret: SecretArea = SecretArea.new()
	secret.name = secret_name
	secret.area = Rect2(Vector2(interior.position) * TILE, Vector2(interior.size) * TILE)
	secret.view = view
	add_child(secret)
	return secret


func _fill(layer: TileMapLayer, rect: Rect2i, tile: Vector2i, alternative: int = 0) -> void:
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			layer.set_cell(Vector2i(x, y), 0, tile, alternative)


# --- Helpers ------------------------------------------------------------------------

func _place(at: Vector2) -> void:
	_player.respawn_at(at)
	_player.face(1)
	var camera: Camera2D = _player.camera
	camera.limit_left = int(bounds.position.x)
	camera.limit_top = int(bounds.position.y)
	camera.limit_right = int(bounds.end.x)
	camera.limit_bottom = int(bounds.end.y)
	camera.reset_smoothing()


func _breakables() -> BreakableTiles:
	return _solid.get_node(^"Breakables") as BreakableTiles


func _cells_gone(rect: Rect2i) -> bool:
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			if _solid.get_cell_source_id(Vector2i(x, y)) != -1:
				return false
	return true


func _count(type: Variant) -> int:
	var count: int = 0
	for node: Node in get_tree().current_scene.get_children():
		if is_instance_of(node, type):
			count += 1
	return count


## Presses [param action] for 2 frames: a scripted press registers on the next physics
## frame, so a 1-frame press can be released before the player sees it.
func _press(action: StringName) -> void:
	Input.action_press(action)
	await _frames(2)
	Input.action_release(action)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _report(check: String, ok: bool, detail: String) -> void:
	print("VISUAL %s %s: %s (frame %d)" % ["PASS" if ok else "FAIL", check, detail, Engine.get_process_frames()])
