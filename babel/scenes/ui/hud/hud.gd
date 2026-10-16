extends Control
## In-game HUD (UI-002): level, EXP to next level, HP and MP bars with numbers, plus a
## centred banner for notices such as relic pickups (REL-003), and for a boss fight
## (BOSS-000) a name card and an HP bar along the bottom with a mark at each phase.
## Drawn with PixelFont so it stays crisp at 640x360.

const BANNER_FRAMES: int = 180
## How long the boss's name card shows, fading in and out.
const NAME_CARD_FRAMES: int = 170
const BOSS_BAR: Rect2 = Rect2(140, 334, 360, 6)
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
## The boss being fought, while its bar shows.
var _boss: Boss
var _name_card_frames: int = 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Events.notice.connect(_on_notice)
	Events.boss_started.connect(_on_boss_started)
	Events.boss_defeated.connect(func(_id: StringName) -> void: _boss = null)


func _process(_delta: float) -> void:
	if _banner_frames > 0 and not get_tree().paused:
		_banner_frames -= 1
	if _name_card_frames > 0 and not get_tree().paused:
		_name_card_frames -= 1
	if _boss != null and not is_instance_valid(_boss):
		_boss = null
	queue_redraw()


func _on_boss_started(boss: Node) -> void:
	_boss = boss as Boss
	_name_card_frames = NAME_CARD_FRAMES


## True while a boss's HP bar shows (tests).
func is_showing_boss() -> bool:
	return _boss != null


## True while the boss's name card shows (tests).
func is_showing_name_card() -> bool:
	return _name_card_frames > 0


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
	if _boss != null:
		_draw_boss_bar()
	if _name_card_frames > 0 and _boss != null:
		_draw_name_card()


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


## The boss's name over a long HP bar along the bottom, with a mark where each phase
## begins.
func _draw_boss_bar() -> void:
	var frame: Rect2 = BOSS_BAR.grow(2.0)
	draw_rect(Rect2(frame.position - Vector2(0, 12), frame.size + Vector2(0, 12)), PANEL)
	draw_rect(frame, BORDER, false, 1.0)
	PixelFont.draw_text(self, BOSS_BAR.position - Vector2(0, 11), tr(_boss.data.display_name), GOLD, 1)
	var ratio: float = float(_boss.health.health) / maxi(1, _boss.health.max_health)
	_bar(BOSS_BAR, ratio, HP)
	for threshold: float in _boss.boss_data().phase_thresholds:
		var x: float = BOSS_BAR.position.x + roundf(BOSS_BAR.size.x * threshold)
		draw_rect(Rect2(x, BOSS_BAR.position.y - 1, 1, BOSS_BAR.size.y + 2), GOLD)


## The name card, Symphony of the Night style: the name large, the title beneath,
## fading in and out.
func _draw_name_card() -> void:
	var shown: int = NAME_CARD_FRAMES - _name_card_frames
	var alpha: float = clampf(minf(shown / 20.0, _name_card_frames / 30.0), 0.0, 1.0)
	var name_text: String = tr(_boss.data.display_name)
	var title_text: String = tr(_boss.boss_data().title)
	var name_w: int = PixelFont.text_width(name_text, 3)
	var title_w: int = PixelFont.text_width(title_text, 1)
	var width: float = maxf(name_w, title_w) + 40.0
	var rect: Rect2 = Rect2(roundf((size.x - width) / 2.0), 70, width, 44)
	draw_rect(rect, Color(PANEL, PANEL.a * alpha))
	draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 1), Color(BORDER, alpha))
	draw_rect(Rect2(rect.position.x, rect.end.y - 1, rect.size.x, 1), Color(BORDER, alpha))
	PixelFont.draw_text(self, Vector2(roundf((size.x - name_w) / 2.0), rect.position.y + 8), name_text, Color(HP.lightened(0.2), alpha), 3)
	PixelFont.draw_text(self, Vector2(roundf((size.x - title_w) / 2.0), rect.position.y + 30), title_text, Color(TEXT, alpha), 1)
