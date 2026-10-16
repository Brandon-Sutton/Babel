extends Node
## Scripted check of Archivist Nabu's shop (NPC-004, UI-018, MAP-005, REL-009) in the
## real game (main.tscn with the sandbox), with real input: Up beside Nabu opens his shop
## and pauses without moving the cursor, buying a Surveyor's Map takes the shekels and
## can't be repeated, a relic is granted at once and shows on Elam, an entry he can't
## afford buys nothing, Back leaves without opening the pause menu, and the map then
## shows the bought section dim. Logs "VISUAL PASS/FAIL". Needs a real window: run it via
## tools/capture.sh (about 600 frames).

const MAIN: PackedScene = preload("res://scenes/main/main.tscn")
const WindowSettle := preload("res://tests/visual/window_settle.gd")
## Where Nabu stands (SandboxRoom.NABU_TILE).
const NABU_X: float = 27 * 16 + 8

var _main: Node
var _player: Player
var _shop: ShopMenu
var _map: MapScreen
var _pause: Control


func _ready() -> void:
	Game.reset()
	WorldMap.reset()
	_main = MAIN.instantiate()
	_main.set(&"continue_from_save", false)
	add_child(_main)
	_player = _main.get(&"player") as Player
	_shop = _main.get_node(^"Menus/ShopMenu") as ShopMenu
	_map = _main.get_node(^"Menus/MapScreen") as MapScreen
	_pause = _main.get_node(^"Menus/PauseMenu") as Control
	_run.call_deferred()


func _run() -> void:
	await WindowSettle.settle(self)
	_player.god_mode = true
	await _check_open()
	await _check_buy_map()
	await _check_buy_relic()
	await _check_too_poor()
	await _check_leave()
	await _check_map_section()
	print("shop_test: done")


## Up beside Nabu opens the shop over a paused game; the cursor stays on the first entry.
func _check_open() -> void:
	_player.respawn_at(Vector2(NABU_X - 24, 320))
	_player.face(1)
	await _frames(30)
	await _press(&"move_up")
	await _frames(3)
	var opened: bool = _shop.visible and get_tree().paused and ShopMenu.is_open
	_report("Up beside Nabu opens his shop", opened and _shop.index == 0 and _shop.shop.id == &"shop_nabu",
			"open and paused=%s, cursor on entry %d, says \"%s\"" % [opened, _shop.index, _shop.message])
	await _frames(20)


## Confirm buys the highlighted map once; a second try buys nothing.
func _check_buy_map() -> void:
	var before: int = Game.stats.shekels
	await _press(&"jump")
	await _frames(3)
	var bought: bool = Game.inventory.count(&"surveyor_map_west") == 1
	var paid: int = before - Game.stats.shekels
	await _frames(20)
	await _press(&"jump")
	await _frames(3)
	var again: int = Game.inventory.count(&"surveyor_map_west")
	_report("buying a Surveyor's Map, once", bought and paid == 50 and again == 1 and Game.stats.shekels == before - 50,
			"bought=%s, paid %d, copies %d, then \"%s\"" % [bought, paid, again, _shop.message])
	await _frames(20)


## Down to the Wanderer's Cube and buy it: the relic's ability is granted at once.
func _check_buy_relic() -> void:
	for i: int in 4:
		await _press(&"ui_down")
		await _frames(2)
	var on_cube: bool = _shop.shop.stock[_shop.index] == &"wanderers_cube"
	var before: int = Game.stats.shekels
	await _press(&"jump")
	await _frames(3)
	_report("buying a relic grants it", on_cube and Game.has_ability(&"lamp_items") and before - Game.stats.shekels == 300,
			"cursor on the cube=%s, owned=%s, paid %d" % [on_cube, Game.has_ability(&"lamp_items"),
			before - Game.stats.shekels])
	await _frames(30)


## The Gazelle Anklet costs more than is left: nothing is bought.
func _check_too_poor() -> void:
	await _press(&"ui_down")
	await _frames(2)
	var before: int = Game.stats.shekels
	await _press(&"jump")
	await _frames(3)
	_report("too poor buys nothing", _shop.shop.stock[_shop.index] == &"gazelle_anklet" and before < 500
			and Game.stats.shekels == before and not Game.has_ability(&"double_jump"),
			"shekels %d, anklet owned=%s, says \"%s\"" % [Game.stats.shekels, Game.has_ability(&"double_jump"), _shop.message])
	await _frames(40)


## Back leaves the shop, unpauses, doesn't open the pause menu; the cube shows on Elam.
func _check_leave() -> void:
	await _press(&"attack_right")
	await _frames(10)
	var page: int = int(_pause.get(&"page"))
	var cube: RelicData = Game.item(&"wanderers_cube") as RelicData
	var worn: bool = false
	for child: Node in _player.equipment_rig.get_children():
		var sprite: Sprite2D = child as Sprite2D
		if sprite != null and sprite.visible and sprite.texture == cube.worn.texture:
			worn = true
	_report("leaving the shop", not _shop.visible and not get_tree().paused and page == 0 and worn,
			"shop shown=%s, paused=%s, pause menu page %d, cube worn=%s" % [_shop.visible, get_tree().paused, page, worn])
	await _frames(20)


## The map shows the bought West Hall: explored (0,0) lit, unvisited (1,0) dim, and the
## East Hall (no map bought) not at all.
func _check_map_section() -> void:
	await _press(&"map")
	await _frames(3)
	var image: Image = await _screen()
	var region: Color = MapScreen.REGION_COLORS[&"test"]
	# Away from Elam's marker in (0,0).
	var here: Color = _pixel(image, _map.cell_rect(Vector2i(0, 0)).position + Vector2(20, 4))
	var west: Color = _pixel(image, _map.cell_rect(Vector2i(1, 0)).get_center())
	var east: Color = _pixel(image, _map.cell_rect(Vector2i(2, 0)).get_center())
	_report("the map shows the bought section", _same(here, region) and _same(west, MapScreen.UNEXPLORED)
			and _same(east, MapScreen.BACKGROUND), "explored %s, West Hall %s (want %s), East Hall %s (want background)"
			% [here.to_html(false), west.to_html(false), MapScreen.UNEXPLORED.to_html(false), east.to_html(false)])
	await _frames(40)
	_map.close()
	await _frames(10)


# --- Helpers ------------------------------------------------------------------------

## True if two colours match to within 8-bit rounding.
func _same(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) < 0.01 and absf(a.g - b.g) < 0.01 and absf(a.b - b.b) < 0.01


func _screen() -> Image:
	await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image()


## The on-screen colour at [param at] (viewport pixels), in sRGB (HDR 2D renders linear).
func _pixel(image: Image, at: Vector2) -> Color:
	return image.get_pixelv(Vector2i(at.floor())).linear_to_srgb()


## Presses [param action] for 2 frames: a scripted press registers on the next physics
## frame, so a 1-frame press can be released before it is seen.
func _press(action: StringName) -> void:
	Input.action_press(action)
	await _frames(2)
	Input.action_release(action)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _report(check: String, ok: bool, detail: String) -> void:
	print("VISUAL %s %s: %s (frame %d)" % ["PASS" if ok else "FAIL", check, detail, Engine.get_process_frames()])
