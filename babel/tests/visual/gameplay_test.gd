extends Node2D
## Scripted gameplay check (PLR/CBT/RPG M1 core). Drives the real Player scene with
## simulated input on a flat greybox floor and measures what happens:
##   walk speed, jump apex, back-dash distance, crouch, sword kill + XP, contact damage
##   with invulnerability frames, and level-up.
## Logs one "VISUAL PASS/FAIL <check>: <measurement>" line per check. Needs a real
## window: run it via tools/capture.sh (about 900 frames).

const Greybox := preload("res://tools/builders/build_greybox_tileset.gd")
const TILE_SET: TileSet = preload("res://assets/tilesets/greybox/greybox_tileset.tres")
const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")
const MUDBORN: PackedScene = preload("res://scenes/actors/enemies/mudborn/mudborn.tscn")
const MUDBORN_DATA: EnemyData = preload("res://data/enemies/mudborn.tres")
const FLOOR_Y: float = 320.0

var _player: Player
var _tuning: PlayerTuning
var _frame: int = 0
var _mark: Vector2
var _apex_y: float = INF
var _enemy: Enemy
var _hp_before: int = 0
var _xp_before: int = 0


func _ready() -> void:
	Game.reset()
	var floor_layer: TileMapLayer = TileMapLayer.new()
	floor_layer.tile_set = TILE_SET
	add_child(floor_layer)
	for x: int in range(-20, 80):
		for y: int in range(20, 23):
			floor_layer.set_cell(Vector2i(x, y), 0, Greybox.SOLID)
	_player = PLAYER_SCENE.instantiate() as Player
	add_child(_player)
	_player.respawn_at(Vector2(160, FLOOR_Y))
	_tuning = _player.tuning


func _physics_process(_delta: float) -> void:
	_frame += 1
	match _frame:
		20:
			_mark = _player.global_position
			Input.action_press(&"move_right")
		80:
			Input.action_release(&"move_right")
			var walked: float = _player.global_position.x - _mark.x
			_report("walk speed", absf(walked - _tuning.walk_speed) <= 4.0,
					"%.1f px in 60 frames (want %.0f)" % [walked, _tuning.walk_speed])
		100:
			_mark = _player.global_position
			_apex_y = INF
			Input.action_press(&"jump")
		170:
			Input.action_release(&"jump")
		200:
			var rise: float = _mark.y - _apex_y
			_report("jump apex", absf(rise - _tuning.jump_height) <= 4.0,
					"%.1f px (want %.0f)" % [rise, _tuning.jump_height])
		220:
			_mark = _player.global_position
			Input.action_press(&"backdash")
		221:
			Input.action_release(&"backdash")
		260:
			var dashed: float = _mark.x - _player.global_position.x
			_report("back-dash", absf(dashed - _tuning.backdash_distance) <= 8.0 and _player.facing == 1,
					"%.1f px backwards, still facing right (want %.0f)" % [dashed, _tuning.backdash_distance])
		270:
			Input.action_press(&"move_down")
		280:
			var crouched: bool = _player.machine.current_name() == &"Crouch" and _player.crouching
			_report("crouch", crouched, "state %s" % _player.machine.current_name())
			Input.action_release(&"move_down")
		300:
			_xp_before = Game.stats.xp
			_enemy = MUDBORN.instantiate() as Enemy
			add_child(_enemy)
			_enemy.global_position = Vector2(_player.global_position.x + 52.0, FLOOR_Y)
	if _frame >= 310 and _frame < 520 and _frame % 22 == 0 and is_instance_valid(_enemy):
		Input.action_press(&"attack_right")
	elif _frame % 22 == 1:
		Input.action_release(&"attack_right")
	match _frame:
		520:
			var killed: bool = not is_instance_valid(_enemy)
			var gained: int = Game.stats.xp - _xp_before
			_report("sword kill + XP", killed and gained == MUDBORN_DATA.xp,
					"enemy dead=%s, XP +%d (want +%d)" % [killed, gained, MUDBORN_DATA.xp])
		540:
			# Contact damage: a Mudborn standing inside the player, no attacks.
			_player.invulnerable_frames = 0
			_hp_before = Game.stats.hp
			_enemy = MUDBORN.instantiate() as Enemy
			add_child(_enemy)
			_enemy.global_position = _player.global_position
		560:
			var first_hit: int = _hp_before - Game.stats.hp
			_hp_before = Game.stats.hp
			_report("contact damage", first_hit > 0, "lost %d HP on touch" % first_hit)
		600:
			var during_iframes: int = _hp_before - Game.stats.hp
			_report("invulnerability frames", during_iframes == 0,
					"lost %d HP in the next 40 frames (want 0)" % during_iframes)
			_enemy.queue_free()
		620:
			var level_before: int = Game.stats.level
			var max_hp_before: int = Game.stats.max_hp
			Game.stats.add_xp(PlayerStats.xp_total_for(level_before + 1) - Game.stats.xp)
			var leveled: bool = Game.stats.level == level_before + 1 and Game.stats.max_hp > max_hp_before
			_report("level up", leveled, "LV %d -> %d, max HP %d -> %d" % [
					level_before, Game.stats.level, max_hp_before, Game.stats.max_hp])
	if _frame > 100 and _frame < 200:
		_apex_y = minf(_apex_y, _player.global_position.y)


func _report(check: String, ok: bool, detail: String) -> void:
	print("VISUAL %s %s: %s" % ["PASS" if ok else "FAIL", check, detail])
