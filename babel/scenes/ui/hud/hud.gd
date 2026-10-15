extends Control
## In-game HUD (UI-002): level, EXP to next level, HP and MP bars with numbers, plus a
## centred banner for notices such as relic pickups (REL-003). Drawn with PixelFont so
## it stays crisp at 640x360.

const BANNER_FRAMES: int = 180
const PANEL: Color = Color(0.043, 0.039, 0.063, 0.8)
const BORDER: Color = Color("82633f")
const GOLD: Color = Color("d4b06e")
const HP: Color = Color("c0263c")
const MP: Color = Color("3d64b5")
const TRACK: Color = Color("242022")
const TEXT: Color = Color("e8dfc4")

var _banner_title: String = ""
var _banner_detail: String = ""
var _banner_frames: int = 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Events.notice.connect(_on_notice)


func _process(_delta: float) -> void:
	if _banner_frames > 0 and not get_tree().paused:
		_banner_frames -= 1
	queue_redraw()


func _on_notice(title: String, detail: String) -> void:
	_banner_title = title
	_banner_detail = detail
	_banner_frames = BANNER_FRAMES


func _draw() -> void:
	# Hidden while a menu pauses the game, like Symphony of the Night.
	if get_tree().paused:
		return
	var stats: PlayerStats = Game.stats
	draw_rect(Rect2(6, 6, 136, 36), PANEL)
	draw_rect(Rect2(6, 6, 136, 36), BORDER, false, 1.0)
	PixelFont.draw_text(self, Vector2(10, 10), "LV %d" % stats.level, GOLD)
	var into_level: int = stats.xp - PlayerStats.xp_total_for(stats.level)
	var level_span: int = maxi(1, PlayerStats.xp_to_next(stats.level))
	_bar(Rect2(36, 11, 102, 3), float(into_level) / level_span, GOLD)
	PixelFont.draw_text(self, Vector2(10, 21), "HP", HP)
	_bar(Rect2(22, 21, 70, 5), float(stats.hp) / maxi(1, stats.max_hp), HP)
	PixelFont.draw_text(self, Vector2(96, 21), "%d/%d" % [stats.hp, stats.max_hp], TEXT)
	PixelFont.draw_text(self, Vector2(10, 31), "MP", MP)
	_bar(Rect2(22, 31, 70, 5), float(stats.mp) / maxi(1, stats.max_mp), MP)
	PixelFont.draw_text(self, Vector2(96, 31), "%d/%d" % [stats.mp, stats.max_mp], TEXT)
	# Embers (Relic Arm ammunition, SotN's hearts) beside the panel.
	draw_rect(Rect2(146, 6, 34, 16), PANEL)
	draw_rect(Rect2(146, 6, 34, 16), BORDER, false, 1.0)
	draw_rect(Rect2(151, 11, 4, 7), Color("ef6a6a"))
	draw_rect(Rect2(152, 9, 2, 2), Color("ef6a6a"))
	draw_rect(Rect2(152, 13, 2, 4), Color("fbe69b"))
	PixelFont.draw_text(self, Vector2(160, 12), "%d" % stats.embers, TEXT)
	# The carried Relic Arm (SUB-001) under the Embers.
	if stats.relic_arm != null:
		var label: String = stats.relic_arm.short_name
		var width: float = maxf(34.0, PixelFont.text_width(label, 1) + 10.0)
		draw_rect(Rect2(146, 24, width, 12), PANEL)
		draw_rect(Rect2(146, 24, width, 12), BORDER, false, 1.0)
		draw_rect(Rect2(149, 27, 5, 6), stats.relic_arm.color)
		PixelFont.draw_text(self, Vector2(157, 27), label, TEXT, 1)
	if _banner_frames > 0:
		_draw_banner()


func _bar(rect: Rect2, ratio: float, color: Color) -> void:
	draw_rect(rect, TRACK)
	draw_rect(Rect2(rect.position, Vector2(roundf(rect.size.x * clampf(ratio, 0.0, 1.0)), rect.size.y)), color)


func _draw_banner() -> void:
	var title_w: int = PixelFont.text_width(_banner_title, 2)
	var detail_w: int = PixelFont.text_width(_banner_detail, 1)
	var width: float = maxf(title_w, detail_w) + 24.0
	var rect: Rect2 = Rect2(roundf((size.x - width) / 2.0), 96, width, 34)
	draw_rect(rect, PANEL)
	draw_rect(rect, BORDER, false, 1.0)
	PixelFont.draw_text(self, Vector2(roundf((size.x - title_w) / 2.0), 102), _banner_title, GOLD, 2)
	PixelFont.draw_text(self, Vector2(roundf((size.x - detail_w) / 2.0), 119), _banner_detail, TEXT)
