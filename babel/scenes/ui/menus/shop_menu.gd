class_name ShopMenu
extends Control
## A shop (UI-018, NPC-004), opened by talking to a shopkeeper such as Archivist Nabu.
## It pauses the game and lists the stock with prices and Elam's shekels; the box beside
## it describes the highlighted entry: stats and effects for gear, what a relic does,
## and for a Surveyor's Map how much of its section he has already explored.
## Entries he can't afford are dimmed, and relics or maps he already owns say OWNED.
## Up/Down choose, Confirm (Z / Enter / A) buys, Back (X / B) or Esc leaves.

## For its text wrapping and gear effect labels.
const PauseMenu := preload("res://scenes/ui/menus/pause_menu.gd")

## True while a shop is showing (the pause menu doesn't open over it).
static var is_open: bool = false

const PANEL: Rect2 = Rect2(16, 14, 608, 332)
const LIST: Rect2 = Rect2(28, 50, 318, 244)
const INFO: Rect2 = Rect2(354, 50, 258, 244)
const LINE: float = 20.0
const SCALE: int = 2
const MESSAGE_FRAMES: int = 120
const BACKGROUND: Color = Color(0.043, 0.039, 0.063, 1.0)
const BORDER: Color = Color("82633f")
const GOLD: Color = Color("d4b06e")
const TEXT: Color = Color("e8dfc4")
const DIM: Color = Color("6c6765")
const GOOD: Color = Color("5fa37c")
const BAD: Color = Color("c0263c")
const HIGHLIGHT: Color = Color(0.83, 0.69, 0.43, 0.14)

## The shop being shown.
var shop: ShopData
## The highlighted entry.
var index: int = 0
## The keeper's last line, or what the last purchase did.
var message: String = ""

var _message_color: Color = TEXT
var _message_frames: int = 0
var _opened_frame: int = -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	add_to_group(&"shop_menu")


## Shows [param with_shop] and pauses the game.
func open(with_shop: ShopData) -> void:
	shop = with_shop
	index = 0
	visible = true
	is_open = true
	get_tree().paused = true
	# The Up press that opened the shop must not also move the cursor.
	_opened_frame = Engine.get_process_frames()
	_say(tr(shop.greeting), TEXT)
	queue_redraw()


func close() -> void:
	visible = false
	get_tree().paused = false
	# Still "open" for the rest of this frame, so the same Esc doesn't open the pause menu.
	_mark_closed.call_deferred()


func _mark_closed() -> void:
	is_open = false


func _process(_delta: float) -> void:
	if not visible or shop == null or Engine.get_process_frames() == _opened_frame:
		return
	if _message_frames > 0:
		_message_frames -= 1
		if _message_frames == 0:
			_say(tr(shop.greeting), TEXT)
	if Input.is_action_just_pressed(&"ui_cancel") or Input.is_action_just_pressed(&"attack_right") \
			or Input.is_action_just_pressed(&"pause"):
		close()
		return
	var count: int = shop.stock.size()
	if count > 0:
		if Input.is_action_just_pressed(&"ui_up"):
			index = (index - 1 + count) % count
		elif Input.is_action_just_pressed(&"ui_down"):
			index = (index + 1) % count
		elif Input.is_action_just_pressed(&"ui_accept") or Input.is_action_just_pressed(&"jump"):
			buy_selected()
	queue_redraw()


## Buys the highlighted entry if Elam can, and says what happened.
func buy_selected() -> void:
	var item_id: StringName = shop.stock[index]
	var item: ItemData = Game.item(item_id)
	match Shop.status(shop, item_id):
		&"ok":
			Shop.buy(shop, item_id)
			_say(tr("BOUGHT %s") % item.display_name, GOOD, MESSAGE_FRAMES)
		&"owned":
			_say(tr("YOU ALREADY HAVE IT"), DIM, MESSAGE_FRAMES)
		&"poor":
			_say(tr("NOT ENOUGH SHEKELS"), BAD, MESSAGE_FRAMES)


func _say(text: String, color: Color, frames: int = 0) -> void:
	message = text
	_message_color = color
	_message_frames = frames


func _draw() -> void:
	if not visible or shop == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.6))
	draw_rect(PANEL, BACKGROUND)
	draw_rect(PANEL, BORDER, false, 1.0)
	_text(PANEL.position + Vector2(12, 10), tr(shop.keeper), GOLD)
	var purse: String = tr("SHEKELS %d") % Game.stats.shekels
	_text(Vector2(PANEL.end.x - 12 - PixelFont.text_width(purse, SCALE), PANEL.position.y + 10), purse, GOLD)
	_draw_list()
	_draw_info()
	_text(Vector2(LIST.position.x, LIST.end.y + 10), message, _message_color, 1)
	_text(Vector2(LIST.position.x, PANEL.end.y - 14), tr("UP/DOWN: CHOOSE    Z: BUY    X: LEAVE"), DIM, 1)


func _draw_list() -> void:
	draw_rect(LIST, BORDER, false, 1.0)
	for i: int in shop.stock.size():
		var item_id: StringName = shop.stock[i]
		var item: ItemData = Game.item(item_id)
		if item == null:
			continue
		var y: float = LIST.position.y + 8.0 + i * LINE
		if i == index:
			draw_rect(Rect2(LIST.position.x + 2, y - 4, LIST.size.x - 4, LINE - 2), HIGHLIGHT)
			_draw_cursor(Vector2(LIST.position.x + 8, y + 1))
		var status: StringName = Shop.status(shop, item_id)
		var color: Color = TEXT if status == &"ok" else DIM
		if i == index and status == &"ok":
			color = GOLD
		_text(Vector2(LIST.position.x + 20, y), item.display_name, color)
		var right: String = tr("OWNED") if status == &"owned" else str(Shop.price(shop, item_id))
		_text(Vector2(LIST.end.x - 10 - PixelFont.text_width(right, SCALE), y), right, color)


## A small gold arrowhead pointing at the highlighted entry.
func _draw_cursor(at: Vector2) -> void:
	for i: int in 4:
		draw_rect(Rect2(at + Vector2(i, i), Vector2(1, 9 - i * 2)), GOLD)


func _draw_info() -> void:
	draw_rect(INFO, BORDER, false, 1.0)
	if shop.stock.is_empty():
		return
	var item: ItemData = Game.item(shop.stock[index])
	if item == null:
		return
	var x: float = INFO.position.x + 10
	var y: float = INFO.position.y + 10
	_text(Vector2(x, y), _kind_label(item), DIM, 1)
	y += 12
	for line: String in PauseMenu._wrap(item.display_name, 28):
		_text(Vector2(x, y), line, GOLD)
		y += 16
	y += 4
	for line: String in PauseMenu._wrap(tr(item.description), 59):
		_text(Vector2(x, y), line, TEXT, 1)
		y += 9
	y += 6
	for line: String in _details(item):
		_text(Vector2(x, y), line, GOLD, 1)
		y += 10


## What the entry gives, in short lines: stats and effects for gear, the section's
## progress for a map. A relic's description says what it does.
func _details(item: ItemData) -> PackedStringArray:
	var lines: PackedStringArray = []
	if item is EquipmentData:
		var gear: EquipmentData = item as EquipmentData
		var stats: PackedStringArray = []
		for field: String in ["attack", "defense", "strength", "constitution", "intelligence", "luck"]:
			var value: int = int(gear.get(field))
			if value != 0:
				stats.append("%s %+d" % [field.substr(0, 3).to_upper(), value])
		if not stats.is_empty():
			lines.append("  ".join(stats))
		var effects: PackedStringArray = PauseMenu._effect_labels(gear)
		if not effects.is_empty():
			lines.append("  ".join(effects))
		lines.append(tr("IN THE BAG: %d") % Game.inventory.count(item.id))
	elif item is MapData:
		var progress: Vector2i = Shop.map_progress(item as MapData)
		lines.append(tr("SECTION: %d SCREENS, %d EXPLORED") % [progress.x, progress.y])
	return lines


func _kind_label(item: ItemData) -> String:
	if item is EquipmentData:
		return tr((item as EquipmentData).kind_label())
	if item is RelicData:
		return tr("RELIC")
	if item is MapData:
		return tr("MAP")
	return tr("ITEM")


func _text(at: Vector2, text: String, color: Color, pixel_scale: int = SCALE) -> void:
	PixelFont.draw_text(self, at, text, color, pixel_scale)
