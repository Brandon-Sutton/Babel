class_name MapScreen
extends Control
## The map (MAP-003, MAP-009), opened with Tab once Elam carries the Builder's Plan
## (REL-008). It pauses the game and draws the world index from WorldMap: explored cells
## filled in their region's colour, and the unvisited cells of the sections whose
## Surveyor's Maps he owns (MAP-005) dim, where he has yet to go. Secret rooms show only
## once found; walls around each room with gaps where rooms connect,
## Elam's position blinking, and the share of the map explored. Arrow keys pan; Tab, Esc
## or Back closes. Without the plan, Tab only says there is no map.

## True while the map is showing (the pause menu doesn't open over it).
static var is_open: bool = false

## Drawn size of one map cell (a 640×360 screen).
const CELL: Vector2 = Vector2(24, 14)
const PANEL: Rect2 = Rect2(16, 14, 608, 332)
## Where the cells are drawn, inside the panel.
const VIEW: Rect2 = Rect2(24, 40, 592, 276)
const PAN_SPEED: float = 4.0
const BLINK_FRAMES: int = 16
## Length of the gap left in a wall where two rooms connect.
const DOOR: int = 6
const SCALE: int = 2
const BACKGROUND: Color = Color(0.043, 0.039, 0.063, 1.0)
const BORDER: Color = Color("82633f")
const GOLD: Color = Color("d4b06e")
const DIM: Color = Color("6c6765")
const UNEXPLORED: Color = Color("1f1b2c")
const UNEXPLORED_WALL: Color = Color("4a4462")
const WALL: Color = Color("e8dfc4")
const MARKER: Color = Color("fbe69b")
const MARKER_EDGE: Color = Color("1a1420")
## Fill of explored cells by region code (GDD §5.2).
const REGION_COLORS: Dictionary[StringName, Color] = {
	&"test": Color("2c4a9a"), &"gte": Color("2c4a9a"), &"shn": Color("7a4a22"),
}
const DEFAULT_REGION: Color = Color("3a3a78")
const DIRECTIONS: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

## Map pixel shown at the centre of the view.
var _pan: Vector2 = Vector2.ZERO
var _frame: int = 0
var _view: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_view = Control.new()
	_view.name = "View"
	_view.position = VIEW.position
	_view.size = VIEW.size
	_view.clip_contents = true
	_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_view.draw.connect(_draw_map)
	add_child(_view)


func _process(_delta: float) -> void:
	if not visible:
		if Input.is_action_just_pressed(&"map") and not get_tree().paused:
			if Game.has_ability(&"map"):
				open()
			else:
				Events.notice.emit(tr("NO MAP"), tr("THE TOWER IS UNCHARTED"))
		return
	_frame += 1
	if Input.is_action_just_pressed(&"map") or Input.is_action_just_pressed(&"pause") \
			or Input.is_action_just_pressed(&"ui_cancel") or Input.is_action_just_pressed(&"attack_right"):
		close()
		return
	_pan += Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down") * PAN_SPEED
	_pan = _pan.clamp(_map_rect().position, _map_rect().end)
	queue_redraw()
	_view.queue_redraw()


## Shows the map centred on Elam and pauses the game.
func open() -> void:
	visible = true
	is_open = true
	_frame = 0
	_pan = (Vector2(WorldMap.player_cell) + WorldMap.player_offset) * CELL
	get_tree().paused = true
	queue_redraw()
	_view.queue_redraw()


func close() -> void:
	visible = false
	get_tree().paused = false
	# Still "open" for the rest of this frame, so the same Esc press doesn't open the
	# pause menu.
	_mark_closed.call_deferred()


func _mark_closed() -> void:
	is_open = false


## How [param cell] is drawn: &"explored" (visited), &"unexplored" (shown dim by a
## Surveyor's Map), or not at all: &"hidden" (a secret not yet found), &"unknown" (not
## visited and on no map he owns) or &"none" (no room there).
static func cell_state(cell: Vector2i) -> StringName:
	var entry: Dictionary = WorldMap.entry_at(cell)
	if entry.is_empty():
		return &"none"
	if WorldMap.is_discovered(cell):
		return &"explored"
	if entry.get("secret", false):
		return &"hidden"
	return &"unexplored" if WorldMap.is_revealed(cell) else &"unknown"


## True if [param cell] is drawn on the map.
static func is_shown(cell: Vector2i) -> bool:
	var state: StringName = cell_state(cell)
	return state == &"explored" or state == &"unexplored"


## What is drawn on the side of [param cell] facing [param direction]: &"none" inside a
## room, &"door" where it opens into another shown room, else &"wall".
static func edge_kind(cell: Vector2i, direction: Vector2i) -> StringName:
	var next: Vector2i = cell + direction
	if not is_shown(next):
		return &"wall"
	if WorldMap.entry_at(next).get("id") == WorldMap.entry_at(cell).get("id"):
		return &"none"
	return &"door" if WorldMap.has_opening(cell, next) else &"wall"


## Where [param cell] is drawn, in this control's coordinates.
func cell_rect(cell: Vector2i) -> Rect2:
	return Rect2(VIEW.position + _to_view(Vector2(cell) * CELL), CELL)


## Where Elam's marker is drawn, in this control's coordinates.
func marker_position() -> Vector2:
	return VIEW.position + _marker_in_view()


## The marker's centre in the view: where Elam stands in his cell, kept off its walls.
func _marker_in_view() -> Vector2:
	var cell_corner: Vector2 = _to_view(Vector2(WorldMap.player_cell) * CELL)
	var inside: Vector2 = (WorldMap.player_offset * CELL).clamp(Vector2(4, 4), CELL - Vector2(4, 4))
	return (cell_corner + inside).round()


func _to_view(map_pixel: Vector2) -> Vector2:
	return (map_pixel - _pan + VIEW.size / 2.0).round()


## The map pixels covered by every cell that can be drawn (the pan stays inside it).
func _map_rect() -> Rect2:
	var rect: Rect2 = Rect2()
	var first: bool = true
	for cell: Vector2i in WorldMap.cells:
		if not is_shown(cell):
			continue
		var cell_area: Rect2 = Rect2(Vector2(cell) * CELL, CELL)
		rect = cell_area if first else rect.merge(cell_area)
		first = false
	return rect


func _draw() -> void:
	if not visible:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.6))
	draw_rect(PANEL, BACKGROUND)
	draw_rect(PANEL, BORDER, false, 1.0)
	draw_rect(VIEW.grow(1.0), BORDER, false, 1.0)
	var title: String = tr("BUILDER'S PLAN")
	PixelFont.draw_text(self, PANEL.position + Vector2(10, 9), title, GOLD, SCALE)
	var explored: String = tr("EXPLORED %d%%") % floori(WorldMap.explored_percent())
	var width: int = PixelFont.text_width(explored, SCALE)
	PixelFont.draw_text(self, Vector2(PANEL.end.x - 10 - width, PANEL.position.y + 9), explored, GOLD, SCALE)
	PixelFont.draw_text(self, Vector2(VIEW.position.x, VIEW.end.y + 8), tr("ARROWS: PAN    TAB: CLOSE"), DIM, 1)


func _draw_map() -> void:
	if not visible:
		return
	var view_rect: Rect2 = Rect2(Vector2.ZERO, VIEW.size)
	for cell: Vector2i in WorldMap.cells:
		var state: StringName = cell_state(cell)
		if state != &"explored" and state != &"unexplored":
			continue
		var rect: Rect2 = Rect2(_to_view(Vector2(cell) * CELL), CELL)
		if not view_rect.intersects(rect):
			continue
		var explored: bool = state == &"explored"
		var region: StringName = StringName(str(WorldMap.entry_at(cell).get("region", "")))
		_view.draw_rect(rect, REGION_COLORS.get(region, DEFAULT_REGION) if explored else UNEXPLORED)
		for direction: Vector2i in DIRECTIONS:
			var kind: StringName = edge_kind(cell, direction)
			if kind != &"none":
				_draw_edge(rect, direction, kind == &"door", WALL if explored else UNEXPLORED_WALL)
	if WorldMap.has_player and floori(_frame / float(BLINK_FRAMES)) % 2 == 0:
		var at: Vector2 = _marker_in_view()
		_view.draw_rect(Rect2(at - Vector2(3, 3), Vector2(6, 6)), MARKER_EDGE)
		_view.draw_rect(Rect2(at - Vector2(2, 2), Vector2(4, 4)), MARKER)


## A 1 px wall along one side of [param rect], with a gap in the middle for a door.
func _draw_edge(rect: Rect2, direction: Vector2i, door: bool, color: Color) -> void:
	var vertical: bool = direction.x != 0
	var length: int = int(rect.size.y if vertical else rect.size.x)
	var start: Vector2 = rect.position
	if direction == Vector2i.RIGHT:
		start.x = rect.end.x - 1
	elif direction == Vector2i.DOWN:
		start.y = rect.end.y - 1
	var along: Vector2 = Vector2(0, 1) if vertical else Vector2(1, 0)
	var thickness: Vector2 = Vector2(1, 0) if vertical else Vector2(0, 1)
	if not door:
		_view.draw_rect(Rect2(start, along * length + thickness), color)
		return
	var gap_start: int = floori((length - DOOR) / 2.0)
	_view.draw_rect(Rect2(start, along * gap_start + thickness), color)
	_view.draw_rect(Rect2(start + along * (gap_start + DOOR), along * (length - gap_start - DOOR) + thickness), color)
