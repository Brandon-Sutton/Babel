extends Node2D
## Scripted tour of the real game (main scene + sandbox room) for what gameplay_test
## doesn't cover: the camera keeping the floor in view, the Gazelle Anklet relic (pickup,
## notice, double jump unlocked), the double jump clearing the 10-tile wall, and the Gate
## Spearman's telegraphed thrust hitting the player. Logs "VISUAL PASS/FAIL" lines.
## Needs a real window: run it via tools/capture.sh (about 760 frames).

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const TILE: float = 16.0
const FLOOR_Y: float = 320.0
const WindowSettle := preload("res://tests/visual/window_settle.gd")

var _main: Node
var _player: Player
var _frame: int = 0
var _notice_seen: String = ""
var _hp_before: int = 0


func _ready() -> void:
	WindowSettle.isolate_input()
	Game.reset()
	_main = MAIN_SCENE.instantiate()
	_main.set(&"continue_from_save", false)
	add_child(_main)
	Events.notice.connect(func(title: String, _detail: String) -> void: _notice_seen = title)


func _physics_process(_delta: float) -> void:
	_frame += 1
	if _player == null:
		_player = _main.get("player") as Player
		return
	match _frame:
		10:
			var camera_bottom: float = _player.camera.get_screen_center_position().y + 180.0
			_report("camera shows the floor", camera_bottom >= FLOOR_Y + 32.0,
					"view bottom y=%.0f, floor top y=%.0f" % [camera_bottom, FLOOR_Y])
			# Relic ledge: tiles 72-79, 6 tiles high; walk in from the left and jump on.
			_teleport(Vector2(68 * TILE, FLOOR_Y))
		20:
			Input.action_press(&"move_right")
			Input.action_press(&"jump")
		50:
			Input.action_release(&"jump")
		120:
			Input.action_release(&"move_right")
			_report("relic pickup", Game.has_ability(&"double_jump") and _notice_seen == "Gazelle Anklet",
					"double_jump=%s, notice '%s'" % [Game.has_ability(&"double_jump"), _notice_seen])
		200:
			# Wall at tiles 92-93, 10 tiles (160 px) high: needs jump + double jump.
			_teleport(Vector2(88 * TILE, FLOOR_Y))
		210:
			Input.action_press(&"move_right")
			Input.action_press(&"jump")
		230:
			Input.action_release(&"jump")
		231:
			Input.action_press(&"jump")
		260:
			Input.action_release(&"jump")
		330:
			Input.action_release(&"move_right")
			_report("double jump clears the wall", _player.global_position.x > 94 * TILE,
					"player x=%.0f (wall ends at %.0f)" % [_player.global_position.x, 94 * TILE])
		400:
			# Gate Spearman at tile 58: stand in its range and let it attack.
			_teleport(Vector2(53 * TILE, FLOOR_Y))
			_player.invulnerable_frames = 0
			_hp_before = Game.stats.hp
		700:
			_report("spearman attacks", Game.stats.hp < _hp_before,
					"HP %d -> %d" % [_hp_before, Game.stats.hp])


func _teleport(at: Vector2) -> void:
	_player.respawn_at(at)
	_player.camera.reset_smoothing()


func _report(check: String, ok: bool, detail: String) -> void:
	print("VISUAL %s %s: %s" % ["PASS" if ok else "FAIL", check, detail])
