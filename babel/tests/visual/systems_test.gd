extends Node2D
## Scripted check of the SotN systems (PLR-011, VFX-012, CBT-005, WLD-007, INV-006,
## SAV-001/002, UI-005/007): back-dash afterimages, saving at an altar (slot 9, deleted
## afterwards), breaking a votive lamp and collecting its drop, hit sparks and screen
## shake, and equipping the Sappara through the pause menu. Logs "VISUAL PASS/FAIL"
## lines. Needs a real window: run it via tools/capture.sh (about 540 frames).

const Greybox := preload("res://tools/builders/build_greybox_tileset.gd")
const TILE_SET: TileSet = preload("res://assets/tilesets/greybox/greybox_tileset.tres")
const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")
const MUDBORN: PackedScene = preload("res://scenes/actors/enemies/mudborn/mudborn.tscn")
const LAMP: PackedScene = preload("res://scenes/world/props/votive_lamp.tscn")
const ALTAR: PackedScene = preload("res://scenes/world/props/save_altar.tscn")
const HUD_SCRIPT: Script = preload("res://scenes/ui/hud/hud.gd")
const MENU_SCRIPT: Script = preload("res://scenes/ui/menus/pause_menu.gd")
const TEST_SLOT: int = 9
const FLOOR_Y: float = 320.0

var _player: Player
var _menu: Control
var _lamp: Node2D
var _enemy: Enemy
var _physics_frame: int = 0
var _menu_frame: int = -1
var _loot_before: int = 0
var _shake_seen: bool = false
var _killed: bool = false
var _attack_before: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Game.reset()
	SaveSystem.active_slot = TEST_SLOT
	SaveSystem.delete_save(TEST_SLOT)
	Events.enemy_killed.connect(func(_id: StringName, _at: Vector2) -> void: _killed = true)
	var floor_layer: TileMapLayer = TileMapLayer.new()
	floor_layer.tile_set = TILE_SET
	floor_layer.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(floor_layer)
	for x: int in range(-20, 60):
		for y: int in range(20, 23):
			floor_layer.set_cell(Vector2i(x, y), 0, Greybox.SOLID)
	var altar: Node2D = ALTAR.instantiate() as Node2D
	altar.position = Vector2(110, FLOOR_Y)
	add_child(altar)
	_lamp = LAMP.instantiate() as Node2D
	_lamp.position = Vector2(250, FLOOR_Y)
	add_child(_lamp)
	_player = PLAYER_SCENE.instantiate() as Player
	_player.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(_player)
	_player.respawn_at(Vector2(200, FLOOR_Y))
	var hud_layer: CanvasLayer = CanvasLayer.new()
	hud_layer.layer = 10
	add_child(hud_layer)
	var hud: Control = Control.new()
	hud.set_script(HUD_SCRIPT)
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_layer.add_child(hud)
	var menu_layer: CanvasLayer = CanvasLayer.new()
	menu_layer.layer = 20
	add_child(menu_layer)
	_menu = Control.new()
	_menu.set_script(MENU_SCRIPT)
	_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_layer.add_child(_menu)


func _physics_process(_delta: float) -> void:
	if get_tree().paused:
		return
	_physics_frame += 1
	match _physics_frame:
		10:
			Input.action_press(&"backdash")
		11:
			Input.action_release(&"backdash")
		16:
			var ghosts: int = 0
			for child: Node in get_children():
				if child is AfterimageTrail.Ghost:
					ghosts += 1
			_report("back-dash afterimages", ghosts > 0, "%d ghosts on screen" % ghosts)
		40:
			Input.action_press(&"move_up")
		41:
			Input.action_release(&"move_up")
		50:
			var data: Dictionary = SaveSystem.load_game(TEST_SLOT)
			var ok: bool = not data.is_empty() and int(data["stats"]["level"]) == Game.stats.level \
					and (data["equipped"] as Dictionary).get("right_hand") == "short_sword" \
					and int((data["inventory"] as Dictionary).get("sappara", 0)) == 1
			_report("save altar", ok, "slot %d written=%s, weapon %s" % [
					TEST_SLOT, not data.is_empty(), (data.get("equipped", {}) as Dictionary).get("right_hand", "-")])
		60:
			Input.action_press(&"move_right")
		95:
			Input.action_release(&"move_right")
			_loot_before = _loot_total()
		100:
			Input.action_press(&"attack_right")
		101:
			Input.action_release(&"attack_right")
		115:
			_report("votive lamp breaks", not is_instance_valid(_lamp), "lamp freed=%s" % (not is_instance_valid(_lamp)))
		120:
			Input.action_press(&"move_right")
		150:
			Input.action_release(&"move_right")
		175:
			var gained: int = _loot_total() - _loot_before
			_report("drop collected", gained > 0, "embers %d, shekels %d, items %d (+%d total)" % [
					Game.stats.embers, Game.stats.shekels, _item_count(), gained])
		180:
			_player.invulnerable_frames = 999
			_enemy = MUDBORN.instantiate() as Enemy
			add_child(_enemy)
			_enemy.global_position = _player.global_position + Vector2(56, 0)
		195:
			var sparks: int = 0
			for child: Node in get_children():
				if child is HitSpark:
					sparks += 1
			_report("hit spark", sparks > 0, "%d sparks after the first hit" % sparks)
		340:
			_report("screen shake on kill", _killed and _shake_seen,
					"enemy killed=%s, camera shook=%s" % [_killed, _shake_seen])
			_attack_before = Game.stats.attack_power()
			_menu_frame = 0
	if _physics_frame >= 185 and _physics_frame < 330 and not _killed:
		if (_physics_frame - 185) % 22 == 0:
			Input.action_press(&"attack_right")
		elif (_physics_frame - 185) % 22 == 1:
			Input.action_release(&"attack_right")
	if _killed and _player.camera.offset != Vector2.ZERO:
		_shake_seen = true


func _process(_delta: float) -> void:
	if _menu_frame < 0:
		return
	_menu_frame += 1
	match _menu_frame:
		5:
			Input.action_press(&"pause")
		6:
			Input.action_release(&"pause")
		20:
			Input.action_press(&"ui_accept")
		21:
			Input.action_release(&"ui_accept")
		40:
			Input.action_press(&"ui_accept")
		41:
			Input.action_release(&"ui_accept")
		60:
			var preview: Dictionary[StringName, int] = Game.stats.preview(&"right_hand", Game.item(&"sappara") as EquipmentData)
			_report("equip preview", preview[&"attack"] > _attack_before,
					"ATK %d -> %d previewed for the Sappara" % [_attack_before, preview[&"attack"]])
		90:
			Input.action_press(&"ui_accept")
		91:
			Input.action_release(&"ui_accept")
		100:
			var weapon: WeaponData = Game.stats.weapon
			var swapped: bool = weapon != null and weapon.id == &"sappara" \
					and Game.inventory.count(&"short_sword") == 1 and Game.inventory.count(&"sappara") == 0
			_report("equip from menu", swapped and Game.stats.attack_power() > _attack_before,
					"right hand %s, ATK %d -> %d, short sword back in inventory=%s" % [
					weapon.id if weapon != null else &"-", _attack_before, Game.stats.attack_power(),
					Game.inventory.count(&"short_sword") == 1])
		130:
			Input.action_press(&"pause")
		131:
			Input.action_release(&"pause")
		140:
			_report("menu closes and unpauses", not get_tree().paused and not _menu.visible,
					"paused=%s" % get_tree().paused)
			SaveSystem.delete_save(TEST_SLOT)
			SaveSystem.active_slot = 0


func _loot_total() -> int:
	return Game.stats.embers + Game.stats.shekels + _item_count()


func _item_count() -> int:
	var count: int = 0
	for id: StringName in Game.inventory.ids():
		count += Game.inventory.count(id)
	return count


func _report(check: String, ok: bool, detail: String) -> void:
	print("VISUAL %s %s: %s" % ["PASS" if ok else "FAIL", check, detail])
