extends Node2D
## Scripted check of the SotN-style specials with real inputs on the real player:
## running (PLR-025), Relic Arms (SUB-001..003), Utterances and weapon arts entered as
## commands (SPL-001..003, SPL-010, SPL-020), and equipment abilities and passives
## (INV-016). Logs "VISUAL PASS/FAIL". Needs a real window: run it via tools/capture.sh
## (about 2000 frames).

const Greybox := preload("res://tools/builders/build_greybox_tileset.gd")
const TILE_SET: TileSet = preload("res://assets/tilesets/greybox/greybox_tileset.tres")
const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")
const MUDBORN: PackedScene = preload("res://scenes/actors/enemies/mudborn/mudborn.tscn")
const FLOOR_Y: float = 320.0
const START_X: float = 300.0
const DIRS: Dictionary[StringName, Vector2i] = {
	&"D": Vector2i(0, 1), &"DF": Vector2i(1, 1), &"F": Vector2i(1, 0), &"B": Vector2i(-1, 0), &"N": Vector2i.ZERO,
}

var _player: Player
var _enemies: Array[Enemy] = []


func _ready() -> void:
	Game.reset()
	var tiles: TileMapLayer = TileMapLayer.new()
	tiles.tile_set = TILE_SET
	add_child(tiles)
	for x: int in range(-40, 120):
		for y: int in range(20, 23):
			tiles.set_cell(Vector2i(x, y), 0, Greybox.SOLID)
	_player = PLAYER_SCENE.instantiate() as Player
	add_child(_player)
	_run.call_deferred()


func _run() -> void:
	# Let the window settle: a focus change while it opens releases every held action.
	await _frames(30)
	await _check_running()
	await _check_relic_arms()
	await _check_spells()
	await _check_weapon_arts()
	await _check_equipment()
	print("specials_test: done")


# --- Running ------------------------------------------------------------------------

func _check_running() -> void:
	await _reset()
	var walk: float = await _measure_speed(false)
	await _reset()
	var run: float = await _measure_speed(true)
	_report("double-tap runs, a press walks", absf(walk - _player.tuning.walk_speed) < 5.0
			and absf(run - _player.tuning.run_speed) < 5.0,
			"walk %.0f px/s (want %.0f), run %.0f px/s (want %.0f)" % [walk, _player.tuning.walk_speed, run,
			_player.tuning.run_speed])
	# Jump out of a run: the air speed stays at run speed.
	await _reset()
	await _start_run()
	await _press(&"jump")
	await _frames(8)
	var air_speed: float = absf(_player.velocity.x)
	var airborne: bool = not _player.is_on_floor()
	Input.action_release(&"move_right")
	await _frames(40)
	_report("a jump out of a run keeps run speed", airborne and absf(air_speed - _player.tuning.run_speed) < 5.0,
			"airborne=%s, air speed %.0f px/s" % [airborne, air_speed])
	# Courier's Mantle raises run speed by 25%.
	await _reset()
	Game.equip(&"mantle", &"courier_mantle")
	var fast: float = await _measure_speed(true)
	Game.equip(&"mantle", &"crimson_mantle")
	var want: float = _player.tuning.run_speed * 1.25
	_report("Courier's Mantle: faster run", absf(fast - want) < 6.0, "run %.0f px/s (want %.0f)" % [fast, want])


func _start_run() -> void:
	await _press(&"move_right")
	await _frames(3)
	Input.action_press(&"move_right")
	await _frames(4)


func _measure_speed(run: bool) -> float:
	if run:
		await _start_run()
	else:
		Input.action_press(&"move_right")
		await _frames(4)
	var x0: float = _player.global_position.x
	await _frames(30)
	var speed: float = (_player.global_position.x - x0) * 2.0
	Input.action_release(&"move_right")
	await _frames(5)
	return speed


# --- Relic Arms ---------------------------------------------------------------------

func _check_relic_arms() -> void:
	await _reset()
	var enemy: Enemy = _spawn_enemy(START_X + 120.0)
	var hp: int = enemy.health.health
	Game.stats.embers = 5
	await _press(&"relic_arm")
	await _frames(40)
	_report("Sling Stone: costs an Ember and hits", Game.stats.embers == 4 and enemy.health.health < hp,
			"embers 5 -> %d, enemy HP %d -> %d" % [Game.stats.embers, hp, enemy.health.health])
	# Up + Attack throws too; the on-screen limit holds back a fourth stone.
	await _reset()
	Game.stats.embers = 10
	var most: int = 0
	for i: int in 5:
		# Up stays held until the attack press has registered.
		Input.action_press(&"move_up")
		await _press(&"attack_right")
		await _frames(1)
		Input.action_release(&"move_up")
		# The stone leaves the hand on Throw.SHOT_FRAME.
		await _frames(6)
		most = maxi(most, get_tree().get_nodes_in_group(PlayerShot.group_for(Game.stats.relic_arm)).size())
		await _frames(10)
	_report("Up + Attack throws; on-screen limit 3", most == 3 and Game.stats.embers == 7,
			"at most %d stones in flight, embers 10 -> %d" % [most, Game.stats.embers])
	await _frames(60)
	# No Embers: nothing is thrown.
	await _reset()
	Game.stats.embers = 0
	await _press(&"relic_arm")
	await _frames(6)
	var shots: int = get_tree().get_nodes_in_group(PlayerShot.group_for(Game.stats.relic_arm)).size()
	_report("no Embers, no throw", shots == 0 and _player.machine.current_name() != &"Throw",
			"shots %d, state %s" % [shots, _player.machine.current_name()])
	# Clay Tablet: arcs up and comes down on the enemy.
	await _reset()
	Game.stats.relic_arm = Game.item(&"clay_tablet") as RelicArmData
	Game.stats.embers = 5
	# Where the arc comes back down (it passes over anything closer).
	enemy = _spawn_enemy(START_X + 150.0)
	hp = enemy.health.health
	await _press(&"relic_arm")
	await _frames(6)
	var rose: bool = false
	for node: Node in get_tree().get_nodes_in_group(PlayerShot.group_for(Game.stats.relic_arm)):
		rose = (node as PlayerShot).velocity.y < 0.0
	await _frames(60)
	_report("Clay Tablet: high arc, 2 Embers, hits", rose and Game.stats.embers == 3 and enemy.health.health < hp,
			"rising at first=%s, embers 5 -> %d, enemy HP %d -> %d" % [rose, Game.stats.embers, hp, enemy.health.health])
	# Picking up another Relic Arm swaps it and drops the old one.
	await _reset()
	Game.stats.relic_arm = Game.item(&"sling_stone") as RelicArmData
	var pickup: Pickup = Pickup.spawn_relic_arm(self, _player.global_position + Vector2(0, -20), &"clay_tablet", 1)
	await _frames(20)
	var dropped: bool = false
	for node: Node in get_children():
		if node is Pickup and node != pickup and (node as Pickup).item_id == &"sling_stone":
			dropped = true
	_report("Relic Arm pickup swaps", Game.stats.relic_arm.id == &"clay_tablet" and dropped,
			"carried %s, old one dropped=%s" % [Game.stats.relic_arm.id, dropped])
	Game.stats.relic_arm = Game.item(&"sling_stone") as RelicArmData


# --- Utterances ---------------------------------------------------------------------

func _check_spells() -> void:
	await _reset()
	var enemy: Enemy = _spawn_enemy(START_X + 130.0)
	var hp: int = enemy.health.health
	Game.stats.mp = Game.stats.max_mp
	await _command(["D", "DF", "F"])
	await _frames(2)
	var cast: bool = _player.machine.current_name() == &"Cast"
	await _frames(14)
	var bolts: int = 0
	for node: Node in get_children():
		if node is PlayerShot and (node as PlayerShot).style == &"bolt":
			bolts += 1
	await _frames(40)
	_report("Išātu: D,DF,F + Attack casts three bolts", cast and bolts == 3
			and Game.stats.mp == Game.stats.max_mp - 6 and enemy.health.health < hp,
			"cast=%s, bolts %d, MP %d/%d, enemy HP %d -> %d" % [cast, bolts, Game.stats.mp, Game.stats.max_mp, hp,
			enemy.health.health])
	# Without enough Breath it fizzles and a normal attack comes out instead.
	await _reset()
	Game.stats.mp = 2
	await _command(["D", "DF", "F"])
	await _frames(2)
	var state: StringName = _player.machine.current_name()
	_report("not enough Breath: fizzle, plain attack", state == &"Attack" and Game.stats.mp == 2,
			"state %s, MP %d" % [state, Game.stats.mp])
	await _frames(30)
	# A plain attack press attacks.
	await _reset()
	await _press(&"attack_right")
	await _frames(1)
	_report("a plain press still attacks", _player.machine.current_name() == &"Attack",
			"state %s" % _player.machine.current_name())
	await _frames(30)


# --- Weapon arts --------------------------------------------------------------------

func _check_weapon_arts() -> void:
	var results: PackedStringArray = []
	var ok: bool = true
	for id: StringName in [&"short_sword", &"sappara", &"bronze_mace", &"lion_greatsword", &"scythe_of_ninurta"]:
		await _reset()
		Game.equip(&"right_hand", id)
		var art: SpellData = Game.stats.weapon.art
		Game.stats.mp = Game.stats.max_mp
		# Whirl hits behind; everything else ahead.
		var behind: bool = art.effect == &"whirl"
		var enemy: Enemy = _spawn_enemy(START_X + (-50.0 if behind else 70.0))
		var hp: int = enemy.health.health
		var x0: float = _player.global_position.x
		await _command(["B", "F"])
		await _frames(2)
		var cast: bool = _player.machine.current_name() == &"Cast"
		var waves: int = 0
		for i: int in art.cast_frames + art.active_frames + 6:
			await _frames(1)
			var count: int = 0
			for node: Node in get_children():
				if node is PlayerShot and (node as PlayerShot).style == &"wave":
					count += 1
			waves = maxi(waves, count)
		await _frames(30)
		var moved: float = _player.global_position.x - x0
		var hit: bool = enemy.health.health < hp
		var spent: bool = Game.stats.mp == Game.stats.max_mp - art.cost_mp
		var effect_ok: bool = hit
		match art.effect:
			&"lunge":
				# Hit-stop on contact freezes part of the dash.
				effect_ok = hit and moved > art.distance * 0.4
			&"shockwave":
				effect_ok = hit and waves == 2
		ok = ok and cast and spent and effect_ok
		results.append("%s %s: cast=%s spent=%s hit=%s%s" % [id, art.effect, cast, spent, hit,
				" moved %.0f" % moved if art.effect == &"lunge" else (" waves %d" % waves if art.effect == &"shockwave" else "")])
	Game.equip(&"right_hand", &"short_sword")
	for line: String in results:
		print("  art " + line)
	_report("every weapon type's art (B,F + Attack)", ok, "%d types" % results.size())


# --- Equipment abilities and passives -----------------------------------------------

func _check_equipment() -> void:
	# Feather Mantle: double jump only while worn.
	await _reset()
	Game.equip(&"mantle", &"feather_mantle")
	var with_mantle: float = await _double_jump_height()
	Game.equip(&"mantle", &"crimson_mantle")
	await _reset()
	var without: float = await _double_jump_height()
	_report("Feather Mantle grants the double jump", with_mantle > without + 40.0,
			"peak with the mantle %.0f px, without %.0f px" % [with_mantle, without])
	# Lamp of Ea: Breath returns over time.
	await _reset()
	Game.equip(&"seal_1", &"lamp_of_ea")
	Game.stats.mp = 0
	await _frames(120)
	var regained: int = Game.stats.mp
	Game.equip(&"seal_1", &"")
	_report("Lamp of Ea: Breath regenerates", regained == 4, "MP 0 -> %d in 2 s (want 4)" % regained)
	# Fang of Lamashtu: hits heal.
	await _reset()
	Game.equip(&"seal_1", &"fang_of_lamashtu")
	Game.stats.hp = Game.stats.max_hp - 20
	var enemy: Enemy = _spawn_enemy(START_X + 40.0)
	await _press(&"attack_right")
	await _frames(30)
	var healed: int = Game.stats.hp - (Game.stats.max_hp - 20)
	Game.equip(&"seal_1", &"")
	_report("Fang of Lamashtu: lifesteal on hits", healed > 0 and enemy.health.health < enemy.health.max_health,
			"healed %d HP from the hit" % healed)
	# Ember Censer: some throws are free.
	await _reset()
	seed(7)
	Game.equip(&"seal_2", &"ember_censer")
	Game.stats.embers = 20
	for i: int in 10:
		await _press(&"relic_arm")
		await _frames(30)
	var spent: int = 20 - Game.stats.embers
	Game.equip(&"seal_2", &"")
	_report("Ember Censer: some throws cost nothing", spent < 10 and spent > 0, "10 throws cost %d Embers" % spent)


func _double_jump_height() -> float:
	Input.action_press(&"jump")
	await _frames(20)
	Input.action_release(&"jump")
	await _frames(2)
	# Held, or the variable-height jump cuts the second jump short.
	Input.action_press(&"jump")
	var peak: float = 0.0
	for i: int in 60:
		await _frames(1)
		peak = maxf(peak, FLOOR_Y - _player.global_position.y)
	Input.action_release(&"jump")
	await _frames(40)
	return peak


# --- Helpers ------------------------------------------------------------------------

## Enters [param steps] (notation tokens) 3 frames apart, then presses Attack.
func _command(steps: Array) -> void:
	for step: String in steps:
		_hold(DIRS[StringName(step)])
		await _frames(3)
	await _press(&"attack_right")
	_hold(Vector2i.ZERO)


## Holds the screen direction for [param direction] (facing right: F is right).
func _hold(direction: Vector2i) -> void:
	for action: StringName in [&"move_left", &"move_right", &"move_up", &"move_down"]:
		Input.action_release(action)
	if direction.x > 0:
		Input.action_press(&"move_right")
	elif direction.x < 0:
		Input.action_press(&"move_left")
	if direction.y > 0:
		Input.action_press(&"move_down")
	elif direction.y < 0:
		Input.action_press(&"move_up")


func _reset() -> void:
	_hold(Vector2i.ZERO)
	for enemy: Enemy in _enemies:
		if is_instance_valid(enemy):
			remove_child(enemy)
			enemy.queue_free()
	_enemies.clear()
	for node: Node in get_children():
		if node is PlayerShot or node is Pickup:
			remove_child(node)
			node.queue_free()
	Game.stats.full_restore()
	_player.respawn_at(Vector2(START_X, FLOOR_Y))
	_player.invulnerable_frames = 0
	_player.running = false
	_player.face(1)
	_player.command_input.clear()
	await _frames(6)


func _spawn_enemy(x: float) -> Enemy:
	var enemy: Enemy = MUDBORN.instantiate() as Enemy
	add_child(enemy)
	enemy.global_position = Vector2(x, FLOOR_Y)
	enemy.set_physics_process(false)
	enemy.contact_hitbox.active = false
	_enemies.append(enemy)
	return enemy


## Presses [param action] for 2 frames: a scripted press registers on the next physics
## frame, so a 1-frame press can be released before the player sees it.
func _press(action: StringName) -> void:
	Input.action_press(action)
	await _frames(2)
	Input.action_release(action)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _report(check: String, ok: bool, detail: String) -> void:
	print("VISUAL %s %s: %s (frame %d)" % ["PASS" if ok else "FAIL", check, detail, Engine.get_process_frames()])
