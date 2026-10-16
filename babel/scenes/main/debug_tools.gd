extends Control
## Debug overlay and cheats (ENG-012, first pass), for playtesting features. Debug builds
## only:
##   F1  overlay: FPS, state, velocity, gait, HP/MP/Embers, Relic Arm, abilities, spells,
##       recent directional inputs (for practising commands); outlines breakable tiles
##       and secret areas (WLD-006)
##   F2  give every item and map, learn every Utterance, grant every relic's ability,
##       add 5000 shekels
##   F3  refill HP, Breath and Embers
##   F4  god mode (hits are ignored)
##   F5  cycle the carried Relic Arm

const TEXT: Color = Color("e8dfc4")
const GOLD: Color = Color("c59c5c")
const PANEL: Color = Color(0.03, 0.02, 0.06, 0.82)

var _overlay: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not OS.is_debug_build():
		queue_free()


func _unhandled_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	match key.keycode:
		KEY_F1:
			_overlay = not _overlay
			BreakableTiles.show_hints = _overlay
		KEY_F2:
			give_everything()
			Events.notice.emit("DEBUG", "EVERY ITEM, SPELL, RELIC AND MAP, +5000 SHEKELS")
		KEY_F3:
			Game.stats.full_restore()
			Game.stats.add_embers(Game.stats.max_embers)
			Events.notice.emit("DEBUG", "HP, BREATH AND EMBERS REFILLED")
		KEY_F4:
			var player: Player = _player()
			if player != null:
				player.god_mode = not player.god_mode
				Events.notice.emit("DEBUG", "GOD MODE " + ("ON" if player.god_mode else "OFF"))
		KEY_F5:
			cycle_relic_arm()
		_:
			return
	get_viewport().set_input_as_handled()


## Adds one of every equipment item and map to the bag, learns every Utterance, grants
## every relic's ability and adds 5000 shekels.
static func give_everything() -> void:
	for id: StringName in Db.ids():
		var entry: Resource = Db.get_entry(id)
		if (entry is EquipmentData or entry is MapData) and Game.inventory.count(id) == 0:
			Game.inventory.add(id)
		elif entry is SpellData and not String(id).begins_with("art_"):
			Game.learn_spell(id)
		elif entry is RelicData:
			Game.grant_ability((entry as RelicData).ability)
	Game.stats.add_shekels(5000)
	Game.stats.emit_changed()


## Switches the carried Relic Arm to the next one in the database.
static func cycle_relic_arm() -> void:
	var arms: Array[RelicArmData] = []
	for id: StringName in Db.ids():
		if Db.get_entry(id) is RelicArmData:
			arms.append(Db.get_entry(id) as RelicArmData)
	if arms.is_empty():
		return
	var index: int = arms.find(Game.stats.relic_arm)
	Game.stats.relic_arm = arms[(index + 1) % arms.size()]
	Game.stats.emit_changed()
	Events.notice.emit(Game.stats.relic_arm.display_name, "RELIC ARM")


func _process(_delta: float) -> void:
	if _overlay:
		queue_redraw()


func _draw() -> void:
	if not _overlay:
		return
	var player: Player = _player()
	var stats: PlayerStats = Game.stats
	var lines: PackedStringArray = ["FPS %d" % Engine.get_frames_per_second()]
	if player != null:
		lines.append("STATE %s%s" % [player.machine.current_name(), "  RUN" if player.running else ""])
		lines.append("VEL %d, %d" % [roundi(player.velocity.x), roundi(player.velocity.y)])
		lines.append("INPUT %s" % player.command_input.recent(player.facing))
		lines.append("GOD MODE" if player.god_mode else "")
	lines.append("HP %d/%d  MP %d/%d  EMBERS %d" % [stats.hp, stats.max_hp, stats.mp, stats.max_mp, stats.embers])
	lines.append("ARM %s" % (stats.relic_arm.short_name if stats.relic_arm != null else "-"))
	var abilities: PackedStringArray = []
	for ability: StringName in [&"double_jump"]:
		if Game.has_ability(ability):
			abilities.append(String(ability).to_upper())
	lines.append("ABILITIES %s" % (", ".join(abilities) if not abilities.is_empty() else "-"))
	var spells: PackedStringArray = []
	for spell: SpellData in Game.known_spells():
		spells.append(spell.command)
	var weapon: WeaponData = stats.weapon
	lines.append("SPELLS %s  ART %s" % [" ".join(spells), weapon.art.command if weapon != null and weapon.art != null else "-"])
	var height: float = 8.0 + lines.size() * 9.0
	draw_rect(Rect2(Vector2(4, 44), Vector2(236, height)), PANEL)
	for i: int in lines.size():
		PixelFont.draw_text(self, Vector2(8, 48 + i * 9), lines[i], GOLD if i == 0 else TEXT, 1)


func _player() -> Player:
	return get_tree().get_first_node_in_group(&"player") as Player
