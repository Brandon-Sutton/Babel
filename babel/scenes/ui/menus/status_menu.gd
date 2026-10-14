extends Control
## Status screen (UI-006, first pass): Pause (Esc / Start) pauses the game and shows the
## character sheet the way Symphony of the Night does: level, experience, HP/MP,
## attributes, attack and defense, the equipped weapon and relics owned.

const PANEL: Color = Color(0.043, 0.039, 0.063, 0.92)
const BORDER: Color = Color("82633f")
const GOLD: Color = Color("d4b06e")
const TEXT: Color = Color("e8dfc4")
const DIM: Color = Color("8a7e71")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pause"):
		visible = not visible
		get_tree().paused = visible
	if visible:
		queue_redraw()


func _draw() -> void:
	var stats: PlayerStats = Game.stats
	var panel: Rect2 = Rect2(150, 50, 340, 260)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.45))
	draw_rect(panel, PANEL)
	draw_rect(panel, BORDER, false, 1.0)
	var x: float = panel.position.x + 16.0
	var y: float = panel.position.y + 14.0
	PixelFont.draw_text(self, Vector2(x, y), "STATUS", GOLD, 2)
	y += 26.0
	var weapon_name: String = stats.weapon.display_name if stats.weapon != null else "-"
	var relics: Array[String] = []
	if Game.has_ability(&"double_jump"):
		relics.append("GAZELLE ANKLET")
	var rows: Array[Array] = [
		["ELAM", "LV %d" % stats.level],
		["EXP %d" % stats.xp, "NEXT %d" % stats.xp_to_next_level()],
		["HP %d/%d" % [stats.hp, stats.max_hp], "MP %d/%d" % [stats.mp, stats.max_mp]],
		["STR %d" % stats.strength, "CON %d" % stats.constitution],
		["INT %d" % stats.intelligence, "LCK %d" % stats.luck],
		["ATK %d" % stats.attack_power(), "DEF %d" % stats.defense()],
	]
	for row: Array in rows:
		PixelFont.draw_text(self, Vector2(x, y), String(row[0]), TEXT, 2)
		PixelFont.draw_text(self, Vector2(x + 170.0, y), String(row[1]), TEXT, 2)
		y += 20.0
	y += 4.0
	PixelFont.draw_text(self, Vector2(x, y), "WEAPON  " + weapon_name, GOLD, 2)
	y += 20.0
	PixelFont.draw_text(self, Vector2(x, y), "RELICS  " + (", ".join(relics) if not relics.is_empty() else "-"), GOLD, 2)
	PixelFont.draw_text(self, Vector2(x, panel.end.y - 14.0), "ESC / START  RESUME", DIM)
