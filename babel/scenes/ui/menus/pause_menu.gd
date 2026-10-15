extends Control
## Pause menu (UI-005), Symphony of the Night style. Pause (Esc / Start) opens it on the
## character sheet with a command list; EQUIP (UI-007) shows the seven equipment slots,
## live stats and a description box. Choosing a slot lists the carried items that fit,
## previews the stat change of the highlighted item (green better, red worse) and equips
## it on confirm. Confirm: Z / Enter / A. Back: X / B. Pause closes from anywhere.

enum Page { CLOSED, MAIN, EQUIP_SLOTS, EQUIP_ITEMS }

const COMMANDS: PackedStringArray = ["EQUIP", "CLOSE"]
const STAT_ROWS: Array[StringName] = [&"attack", &"defense", &"strength", &"constitution", &"intelligence", &"luck"]
const STAT_LABELS: Dictionary[StringName, String] = {
	&"attack": "ATK", &"defense": "DEF", &"strength": "STR", &"constitution": "CON",
	&"intelligence": "INT", &"luck": "LCK",
}
const REMOVE: StringName = &""
const SCALE: int = 2
const LINE: float = 18.0
const PANEL: Color = Color(0.043, 0.039, 0.063, 1.0)
const BORDER: Color = Color("82633f")
const GOLD: Color = Color("d4b06e")
const TEXT: Color = Color("e8dfc4")
const DIM: Color = Color("6c6765")
const BETTER: Color = Color("5fa37c")
const WORSE: Color = Color("c0263c")

var page: Page = Page.CLOSED
var _command: int = 0
var _slot_index: int = 0
var _item_index: int = 0
var _items: Array[StringName] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pause"):
		if page == Page.CLOSED:
			open()
		else:
			close()
		return
	if page == Page.CLOSED:
		return
	var up: bool = Input.is_action_just_pressed(&"ui_up")
	var down: bool = Input.is_action_just_pressed(&"ui_down")
	var accept: bool = Input.is_action_just_pressed(&"ui_accept") or Input.is_action_just_pressed(&"jump")
	var back: bool = Input.is_action_just_pressed(&"ui_cancel") or Input.is_action_just_pressed(&"attack_right")
	match page:
		Page.MAIN:
			_command = _step(_command, COMMANDS.size(), up, down)
			if accept:
				if COMMANDS[_command] == "EQUIP":
					page = Page.EQUIP_SLOTS
				else:
					close()
			elif back:
				close()
		Page.EQUIP_SLOTS:
			_slot_index = _step(_slot_index, PlayerStats.SLOTS.size(), up, down)
			if accept:
				_open_item_list()
			elif back:
				page = Page.MAIN
		Page.EQUIP_ITEMS:
			_item_index = _step(_item_index, _items.size(), up, down)
			if accept and not _items.is_empty():
				Game.equip(_selected_slot(), _items[_item_index])
				page = Page.EQUIP_SLOTS
			elif back:
				page = Page.EQUIP_SLOTS
	queue_redraw()


## Opens the menu on the main page and pauses the game.
func open() -> void:
	page = Page.MAIN
	_command = 0
	visible = true
	get_tree().paused = true
	queue_redraw()


func close() -> void:
	page = Page.CLOSED
	visible = false
	get_tree().paused = false


func _step(index: int, count: int, up: bool, down: bool) -> int:
	if count <= 0:
		return 0
	if up:
		return (index - 1 + count) % count
	if down:
		return (index + 1) % count
	return index


func _selected_slot() -> StringName:
	return PlayerStats.SLOTS[_slot_index]


## Lists the carried items that fit the selected slot (plus "remove" when it's worn).
func _open_item_list() -> void:
	_items.clear()
	var slot: StringName = _selected_slot()
	for id: StringName in Game.inventory.ids():
		if PlayerStats.fits(Game.item(id) as EquipmentData, slot):
			_items.append(id)
	if Game.stats.equipped.has(slot):
		_items.append(REMOVE)
	_item_index = 0
	page = Page.EQUIP_ITEMS


## The item whose stats and description are shown: the highlighted list entry, or what
## the selected slot holds.
func _focused_item() -> EquipmentData:
	if page == Page.EQUIP_ITEMS and not _items.is_empty():
		return Game.item(_items[_item_index]) as EquipmentData if _items[_item_index] != REMOVE else null
	if page == Page.EQUIP_SLOTS or page == Page.EQUIP_ITEMS:
		return Game.stats.equipped.get(_selected_slot())
	return null


func _draw() -> void:
	if page == Page.CLOSED:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.5))
	var panel: Rect2 = Rect2(16, 14, 608, 332)
	draw_rect(panel, PANEL)
	draw_rect(panel, BORDER, false, 1.0)
	if page == Page.MAIN:
		_draw_main()
	else:
		_draw_equip()


func _text(at: Vector2, text: String, color: Color = TEXT, pixel_scale: int = SCALE) -> void:
	PixelFont.draw_text(self, at, text, color, pixel_scale)


func _draw_main() -> void:
	var stats: PlayerStats = Game.stats
	var totals: Dictionary[StringName, int] = stats.summary()
	_text(Vector2(32, 28), "STATUS", GOLD)
	var rows: Array[Array] = [
		["ELAM", "LV %d" % stats.level],
		["EXP %d" % stats.xp, "NEXT %d" % stats.xp_to_next_level()],
		["HP %d/%d" % [stats.hp, stats.max_hp], "MP %d/%d" % [stats.mp, stats.max_mp]],
		["STR %d" % totals[&"strength"], "CON %d" % totals[&"constitution"]],
		["INT %d" % totals[&"intelligence"], "LCK %d" % totals[&"luck"]],
		["ATK %d" % totals[&"attack"], "DEF %d" % totals[&"defense"]],
		["EMBERS %d" % stats.embers, "SHEKELS %d" % stats.shekels],
	]
	var y: float = 56.0
	for row: Array in rows:
		_text(Vector2(32, y), String(row[0]))
		_text(Vector2(200, y), String(row[1]))
		y += LINE + 2.0
	var relics: Array[String] = []
	if Game.has_ability(&"double_jump"):
		relics.append("GAZELLE ANKLET")
	_text(Vector2(32, y + 6), "RELICS  " + (", ".join(relics) if not relics.is_empty() else "-"), GOLD)
	var box: Rect2 = Rect2(440, 52, 160, 22.0 + COMMANDS.size() * LINE)
	draw_rect(box, BORDER, false, 1.0)
	for i: int in COMMANDS.size():
		var cy: float = box.position.y + 12.0 + i * LINE
		if i == _command:
			_text(Vector2(box.position.x + 10, cy), ">", GOLD)
		_text(Vector2(box.position.x + 26, cy), COMMANDS[i], GOLD if i == _command else TEXT)
	_text(Vector2(32, 322), "Z / ENTER  SELECT     X  BACK     ESC  CLOSE", DIM, 1)


func _draw_equip() -> void:
	var stats: PlayerStats = Game.stats
	_text(Vector2(32, 28), "EQUIP", GOLD)
	var shekels: String = "SHEKELS %d" % stats.shekels
	_text(Vector2(600 - PixelFont.text_width(shekels, SCALE), 28), shekels, TEXT)
	var list_box: Rect2 = Rect2(28, 50, 312, 196)
	draw_rect(list_box, BORDER, false, 1.0)
	if page == Page.EQUIP_SLOTS:
		_draw_slots(list_box)
	else:
		_draw_item_list(list_box)
	_draw_stats(Rect2(352, 50, 256, 196))
	_draw_description(Rect2(28, 254, 580, 78))


func _draw_slots(box: Rect2) -> void:
	for i: int in PlayerStats.SLOTS.size():
		var slot: StringName = PlayerStats.SLOTS[i]
		var y: float = box.position.y + 12.0 + i * (LINE + 6.0)
		var selected: bool = i == _slot_index
		if selected:
			_text(Vector2(box.position.x + 6, y), ">", GOLD)
		_text(Vector2(box.position.x + 20, y), PlayerStats.SLOT_LABELS[slot], GOLD if selected else DIM)
		var item: EquipmentData = stats_item(slot)
		if slot == &"left_hand" and Game.stats.hands_full():
			# Taken by the two-handed weapon; equipping here takes that weapon off.
			_text(Vector2(box.position.x + 92, y), "(TWO-HANDED)", DIM)
			continue
		_text(Vector2(box.position.x + 92, y), item.display_name if item != null else "-", TEXT if selected else Color(TEXT, 0.8))


func stats_item(slot: StringName) -> EquipmentData:
	return Game.stats.equipped.get(slot)


func _draw_item_list(box: Rect2) -> void:
	_text(Vector2(box.position.x + 8, box.position.y + 8), PlayerStats.SLOT_LABELS[_selected_slot()], GOLD)
	if _items.is_empty():
		_text(Vector2(box.position.x + 20, box.position.y + 34), "NOTHING TO EQUIP", DIM)
		return
	for i: int in _items.size():
		var y: float = box.position.y + 34.0 + i * LINE
		var selected: bool = i == _item_index
		if selected:
			_text(Vector2(box.position.x + 6, y), ">", GOLD)
		var label: String = "(REMOVE)"
		if _items[i] != REMOVE:
			var item: ItemData = Game.item(_items[i])
			label = item.display_name if item != null else String(_items[i])
			var count: int = Game.inventory.count(_items[i])
			if count > 1:
				label += "  X%d" % count
		_text(Vector2(box.position.x + 20, y), label, TEXT if selected else Color(TEXT, 0.75))


func _draw_stats(box: Rect2) -> void:
	draw_rect(box, BORDER, false, 1.0)
	var now: Dictionary[StringName, int] = Game.stats.summary()
	var after: Dictionary[StringName, int] = now
	if page == Page.EQUIP_ITEMS and not _items.is_empty():
		after = Game.stats.preview(_selected_slot(), _focused_item())
	for i: int in STAT_ROWS.size():
		var key: StringName = STAT_ROWS[i]
		var y: float = box.position.y + 12.0 + i * (LINE + 8.0)
		_text(Vector2(box.position.x + 12, y), STAT_LABELS[key], GOLD)
		_text(Vector2(box.position.x + 60, y), "%3d" % now[key])
		if after[key] != now[key]:
			var color: Color = BETTER if after[key] > now[key] else WORSE
			_text(Vector2(box.position.x + 100, y), ">", color)
			_text(Vector2(box.position.x + 120, y), "%3d" % after[key], color)


func _draw_description(box: Rect2) -> void:
	draw_rect(box, BORDER, false, 1.0)
	var item: EquipmentData = _focused_item()
	if item == null:
		var hint: String = "REMOVE THE ITEM IN THIS SLOT" if page == Page.EQUIP_ITEMS else "EMPTY"
		_text(Vector2(box.position.x + 10, box.position.y + 10), hint, DIM)
		return
	var header: String = item.display_name
	var details: PackedStringArray = [item.kind_label()]
	if PlayerStats.is_two_handed(item):
		details.append("TWO-HANDED")
	if item.attack != 0:
		details.append("ATK %d" % item.attack)
	if item.defense != 0:
		details.append("DEF %d" % item.defense)
	_text(Vector2(box.position.x + 10, box.position.y + 8), header, GOLD)
	var detail_text: String = "  ".join(details)
	_text(Vector2(box.end.x - 10 - PixelFont.text_width(detail_text, 1), box.position.y + 11), detail_text, DIM, 1)
	var y: float = box.position.y + 28.0
	for line: String in _wrap(item.description, 70):
		_text(Vector2(box.position.x + 10, y), line, TEXT)
		y += 15.0


## Splits [param text] into lines of at most [param width] characters at spaces.
static func _wrap(text: String, width: int) -> PackedStringArray:
	var lines: PackedStringArray = []
	var current: String = ""
	for word: String in text.split(" ", false):
		var candidate: String = word if current.is_empty() else current + " " + word
		if candidate.length() > width and not current.is_empty():
			lines.append(current)
			current = word
		else:
			current = candidate
	if not current.is_empty():
		lines.append(current)
	return lines
