extends Node
## Scripted check of the boss framework (BOSS-000) and severable parts (BOSS-030) in the
## real game, against the Weeping Effigy in the test arena: walking in locks the arena
## (gate, camera, name card, HP bar) and the boss begins after its delay; the sword tears
## off its front arm (the piece falls, the stump shows) and the slam is gone; tearing off
## the mask unlocks the gaze, which it then uses; half HP starts phase 2; death drops the
## reward, opens the gate, returns the camera and saves the flag; a defeated boss stays
## dead. Logs "VISUAL PASS/FAIL". Needs a real window: run it via tools/capture.sh
## (about 1500 frames).

const MAIN: PackedScene = preload("res://scenes/main/main.tscn")
const ARENA_ROOM: PackedScene = preload("res://scenes/world/rooms/test/boss_arena_room.tscn")
const SANDBOX: PackedScene = preload("res://scenes/world/rooms/test/sandbox_room.tscn")
const WindowSettle := preload("res://tests/visual/window_settle.gd")
const FLOOR_Y: float = 320.0

var _main: Node
var _player: Player
var _hud: Node
var _arena: BossArena
var _boss: Boss
var _phase_seen: int = -1


func _ready() -> void:
	Game.reset()
	WorldMap.reset()
	_main = MAIN.instantiate()
	_main.set(&"continue_from_save", false)
	add_child(_main)
	_player = _main.get(&"player") as Player
	_hud = _main.get_node(^"HUD/Hud")
	_run.call_deferred()


func _run() -> void:
	await WindowSettle.settle(self)
	_player.god_mode = true
	_main.call(&"warp_to", ARENA_ROOM)
	await _frames(10)
	_find_arena()
	_boss.phase_changed.connect(func(phase: int) -> void: _phase_seen = phase)
	await _check_lock()
	await _check_sever_arm()
	await _check_mask_and_gaze()
	await _check_phase_two()
	await _check_death()
	await _check_stays_dead()
	print("boss_test: done")


func _find_arena() -> void:
	var room: Node2D = _main.get(&"room") as Node2D
	_arena = room.get_node(^"Arena") as BossArena
	_boss = _arena.boss


## Walking in: the gate drops, the camera frames the arena, the name card and the HP bar
## show, and the boss begins only after its delay. The gate holds Elam in.
func _check_lock() -> void:
	var idle_before: bool = not _arena.is_locked() and not _boss.started
	Input.action_press(&"move_right")
	for i: int in 200:
		await _frames(1)
		if _arena.is_locked():
			break
	Input.action_release(&"move_right")
	var name_card: bool = _hud.call(&"is_showing_name_card")
	var bar: bool = _hud.call(&"is_showing_boss")
	var waited: bool = not _boss.started
	await _frames(40)
	var camera: Camera2D = _player.camera
	var framed: bool = camera.limit_left == int(_arena.area.position.x) and camera.limit_right == int(_arena.area.end.x)
	await _frames(40)
	var begun: bool = _boss.started
	Input.action_press(&"move_left")
	await _frames(70)
	Input.action_release(&"move_left")
	var held_in: bool = _player.global_position.x >= _arena.gates[0].end.x - 2.0
	_report("entering locks the arena", idle_before and _arena.is_locked() and name_card and bar and waited and framed
			and begun and held_in, "locked=%s, name card=%s, HP bar=%s, waited=%s then began=%s, camera framed=%s, held in=%s (x %.0f)"
			% [_arena.is_locked(), name_card, bar, waited, begun, framed, held_in, _player.global_position.x])


## Sword strikes on the front arm: it tears off, the piece falls and the stump shows,
## and the boss pays bonus HP. Its slam is gone.
func _check_sever_arm() -> void:
	var arm: BossPart = _boss.parts[&"arm_front"]
	var hp_before: int = _boss.health.health
	var presses: int = 0
	while not arm.is_severed() and presses < 30:
		_player.respawn_at(Vector2(_boss.global_position.x - 86.0, FLOOR_Y))
		_player.face(1)
		await _frames(2)
		await _press(&"attack_right")
		await _frames(22)
		presses += 1
	await _frames(20)
	var pieces: int = 0
	for node: Node in get_children():
		if node is SeveredPiece:
			pieces += 1
	var stump: bool = (arm.get_node(^"Beneath") as Sprite2D).visible and not (arm.get_node(^"Intact") as Sprite2D).visible
	var lost: int = hp_before - _boss.health.health
	var slam_gone: bool = not _ids(PatternSequencer.available(_boss.boss_data().patterns, _boss.phase, _boss.severed, 100.0)).has(&"slam")
	_report("the sword tears off an arm", arm.is_severed() and pieces > 0 and stump and lost > arm.max_hp and slam_gone,
			"severed after %d strikes, pieces falling %d, stump shown=%s, boss lost %d HP, slam gone=%s"
			% [presses, pieces, stump, lost, slam_gone])
	await _frames(30)


## Tearing off the mask unlocks the gaze, and the boss then uses it: bolts fly.
func _check_mask_and_gaze() -> void:
	var mask: BossPart = _boss.parts[&"mask"]
	while not mask.is_severed():
		_hit(mask, 30)
	var seen: Dictionary[StringName, bool] = {}
	var bolts: int = 0
	for i: int in 500:
		await _frames(1)
		if _boss.current != null:
			seen[_boss.current.id] = true
		bolts = maxi(bolts, _shots(&"bolt"))
		if seen.has(&"gaze") and bolts > 0:
			break
	_report("losing the mask unlocks the gaze", mask.is_severed() and seen.has(&"gaze") and bolts > 0 and not seen.has(&"slam"),
			"mask severed=%s, patterns seen %s, bolts in flight %d" % [mask.is_severed(), seen.keys(), bolts])


## Half HP starts phase 2: the boss flinches, and patterns speed up.
func _check_phase_two() -> void:
	var limit: int = _boss.health.max_health / 2
	while _boss.health.health > limit:
		_hit(null, 20)
	await _frames(5)
	_report("half HP starts phase 2", _boss.phase == 1 and _phase_seen == 1 and _boss.speed() > 1.0,
			"phase %d (signal %d), speed x%.2f, HP %d/%d" % [_boss.phase, _phase_seen, _boss.speed(), _boss.health.health,
			_boss.health.max_health])
	await _frames(60)


## Death: the sequence plays, the reward drops, the gate opens, the camera returns, the
## flag is saved and the HP bar goes.
func _check_death() -> void:
	var xp_before: int = Game.stats.xp
	while _boss.health.is_alive():
		_hit(null, 60)
	var dying: bool = _boss.is_dying()
	await _frames(Boss.DEATH_SEQUENCE_FRAMES + 40)
	var gone: bool = not is_instance_valid(_boss)
	var reward: bool = false
	for node: Node in (_main.get(&"room") as Node).get_node(^"Entities").get_children():
		if node is Pickup and (node as Pickup).item_id == _arena_reward():
			reward = true
	var camera: Camera2D = _player.camera
	var bounds: Rect2 = _main.get(&"room").get(&"bounds")
	var returned: bool = camera.limit_left == int(bounds.position.x) and camera.limit_right == int(bounds.end.x)
	var gate_open: bool = not _arena.is_locked() and _gate_bodies() == 0
	var flagged: bool = Game.is_flag(_arena.flag())
	var bar: bool = _hud.call(&"is_showing_boss")
	_report("death drops the reward and opens the arena", dying and gone and reward and gate_open and returned and flagged
			and not bar and Game.stats.xp > xp_before, "dying=%s, freed=%s, reward dropped=%s, gate open=%s, camera back=%s, flag=%s, bar hidden=%s, XP +%d"
			% [dying, gone, reward, gate_open, returned, flagged, not bar, Game.stats.xp - xp_before])


## Coming back after the fight: no boss, the gate stays open.
func _check_stays_dead() -> void:
	_main.call(&"warp_to", SANDBOX)
	await _frames(10)
	_main.call(&"warp_to", ARENA_ROOM)
	await _frames(10)
	var room: Node = _main.get(&"room") as Node
	var arena: BossArena = room.get_node(^"Arena") as BossArena
	var bosses: int = 0
	for node: Node in room.get_node(^"Entities").get_children():
		if node is Boss and not node.is_queued_for_deletion():
			bosses += 1
	_report("a defeated boss stays dead", bosses == 0 and arena.state == BossArena.ArenaState.DONE,
			"bosses left %d, arena done=%s" % [bosses, arena.state == BossArena.ArenaState.DONE])
	await _frames(30)


# --- Helpers ------------------------------------------------------------------------

## One hit of [param power] on [param part] (or the body when null), past the boss's
## invulnerability frames.
func _hit(part: BossPart, power: int) -> void:
	_boss.health.invulnerable_frames_left = 0
	var info: DamageInfo = DamageInfo.new()
	info.attack = power
	info.position = _boss.global_position + Vector2(0, -60)
	if part != null:
		_boss.hit_part(info, part)
	else:
		_boss.hurtbox.receive_hit(info)


func _arena_reward() -> StringName:
	return (Db.get_entry(&"test_effigy") as BossData).reward


func _gate_bodies() -> int:
	var count: int = 0
	for child: Node in _arena.get_children():
		if child is StaticBody2D and not child.is_queued_for_deletion():
			count += 1
	return count


func _shots(style: StringName) -> int:
	var count: int = 0
	for node: Node in (_main.get(&"room") as Node).get_node(^"Entities").get_children():
		if node is EnemyShot and (node as EnemyShot).style == style:
			count += 1
	return count


func _ids(patterns: Array[BossPattern]) -> Array[StringName]:
	var ids: Array[StringName] = []
	for pattern: BossPattern in patterns:
		ids.append(pattern.id)
	return ids


## Presses [param action] for 2 frames: a scripted press registers on the next physics
## frame, so a 1-frame press can be released before it is seen.
func _press(action: StringName) -> void:
	Input.action_press(action)
	await _frames(2)
	Input.action_release(action)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _report(check: String, ok: bool, detail: String) -> void:
	print("VISUAL %s %s: %s (frame %d)" % ["PASS" if ok else "FAIL", check, detail, Engine.get_process_frames()])
