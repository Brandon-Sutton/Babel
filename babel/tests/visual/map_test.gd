extends Node
## Scripted check of the map (MAP-001..003, MAP-009, REL-008) in the real game (main.tscn
## with the sandbox): cells are discovered where Elam stands, Tab opens the map and
## pauses, explored cells are drawn in the region's colour and unexplored ones dim while
## secret rooms stay hidden, Esc closes the map without opening the pause menu, there is
## no map without the Builder's Plan, and a found secret room appears with a door into
## it. Logs "VISUAL PASS/FAIL". Needs a real window: run it via tools/capture.sh (about
## 700 frames).

const MAIN: PackedScene = preload("res://scenes/main/main.tscn")
const WindowSettle := preload("res://tests/visual/window_settle.gd")

var _main: Node
var _player: Player
var _map: MapScreen
var _pause: Control


func _ready() -> void:
	Game.reset()
	WorldMap.reset()
	_main = MAIN.instantiate()
	_main.set(&"continue_from_save", false)
	add_child(_main)
	_player = _main.get(&"player") as Player
	_map = _main.get_node(^"Menus/MapScreen") as MapScreen
	_pause = _main.get_node(^"Menus/PauseMenu") as Control
	_run.call_deferred()


func _run() -> void:
	await WindowSettle.settle(self)
	_player.god_mode = true
	await _check_discovery()
	await _check_open_and_draw()
	await _check_close_with_pause()
	await _check_needs_plan()
	await _check_secret_room()
	print("map_test: done")


## Standing in a cell discovers it; cells not yet reached stay undiscovered.
func _check_discovery() -> void:
	var start: bool = WorldMap.is_discovered(Vector2i(0, 0))
	_player.respawn_at(Vector2(1000, 320))
	await _frames(5)
	var second: bool = WorldMap.is_discovered(Vector2i(1, 0))
	var third: bool = WorldMap.is_discovered(Vector2i(2, 0))
	_report("cells are discovered where Elam stands", start and second and not third
			and WorldMap.player_cell == Vector2i(1, 0),
			"start cell=%s, second=%s, third (not reached)=%s, Elam in %s" % [start, second, third, WorldMap.player_cell])


## Tab opens the map over a paused game; the cells are drawn by their state.
func _check_open_and_draw() -> void:
	await _press(&"map")
	await _frames(3)
	var opened: bool = _map.visible and get_tree().paused and MapScreen.is_open
	var image: Image = await _screen()
	var explored: Color = _pixel(image, _map.cell_rect(Vector2i(0, 0)).get_center())
	var unexplored: Color = _pixel(image, _map.cell_rect(Vector2i(2, 0)).get_center())
	var hidden: Color = _pixel(image, _map.cell_rect(Vector2i(3, 0)).get_center())
	var region: Color = MapScreen.REGION_COLORS[&"test"]
	var ok: bool = opened and _same(explored, region) and _same(unexplored, MapScreen.UNEXPLORED) \
			and _same(hidden, MapScreen.BACKGROUND)
	_report("Tab shows explored, unexplored and hidden cells", ok,
			"open and paused=%s, explored cell %s (want %s), unexplored %s, secret %s (want background)"
			% [opened, explored.to_html(false), region.to_html(false), unexplored.to_html(false), hidden.to_html(false)])
	await _frames(40)


## Esc closes the map and doesn't open the pause menu with the same press.
func _check_close_with_pause() -> void:
	await _press(&"pause")
	await _frames(3)
	var page: int = int(_pause.get(&"page"))
	_report("Esc closes the map, not into the pause menu", not _map.visible and not get_tree().paused
			and not MapScreen.is_open and page == 0, "map shown=%s, paused=%s, pause menu page %d"
			% [_map.visible, get_tree().paused, page])


## Without the Builder's Plan, Tab doesn't open anything.
func _check_needs_plan() -> void:
	Game.abilities.erase(&"map")
	await _press(&"map")
	await _frames(3)
	var shown: bool = _map.visible
	Game.grant_ability(&"map")
	if shown:
		_map.close()
	_report("no Builder's Plan, no map", not shown, "map shown=%s" % shown)
	await _frames(5)


## Entering the east secret room puts it on the map, with a door from the main room.
func _check_secret_room() -> void:
	# Through the last screen of the main room, then into the secret room.
	_player.respawn_at(Vector2(1700, 320))
	await _frames(5)
	_player.respawn_at(Vector2(126 * 16, 320))
	await _frames(30)
	var found: bool = WorldMap.is_discovered(Vector2i(3, 0))
	await _press(&"map")
	await _frames(3)
	var image: Image = await _screen()
	var region: Color = MapScreen.REGION_COLORS[&"test"]
	var room_rect: Rect2 = _map.cell_rect(Vector2i(3, 0))
	var drawn: bool = _same(_pixel(image, room_rect.get_center() + Vector2(0, -4)), region)
	var main_rect: Rect2 = _map.cell_rect(Vector2i(2, 0))
	var gap: Color = _pixel(image, Vector2(main_rect.end.x - 1, main_rect.get_center().y))
	var wall: Color = _pixel(image, Vector2(main_rect.end.x - 1, main_rect.position.y + 2))
	var door: bool = MapScreen.edge_kind(Vector2i(2, 0), Vector2i.RIGHT) == &"door" \
			and _same(gap, region) and _same(wall, MapScreen.WALL)
	_report("a found secret room appears, with a door", found and drawn and door,
			"discovered=%s, drawn=%s, door gap %s / wall %s, explored %d%%"
			% [found, drawn, gap.to_html(false), wall.to_html(false), floori(WorldMap.explored_percent())])
	await _frames(60)
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
	var linear: Color = image.get_pixelv(Vector2i(at.floor()))
	var srgb: Color = linear.linear_to_srgb()
	return Color(snappedf(srgb.r, 1.0 / 255.0), snappedf(srgb.g, 1.0 / 255.0), snappedf(srgb.b, 1.0 / 255.0), 1.0)


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
