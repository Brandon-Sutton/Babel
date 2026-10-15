extends Node2D
## Scripted check that level geometry blocks attacks (CBT-013): a sword and a scythe
## swing don't hurt an enemy behind a wall but do once the wall is gone, a one-way
## platform doesn't block, a swing into the wall strikes sparks there, and the Gate
## Spearman's stab doesn't reach the player through a wall. Logs "VISUAL PASS/FAIL".
## Needs a real window: run it via tools/capture.sh (about 700 frames).

const Greybox := preload("res://tools/builders/build_greybox_tileset.gd")
const TILE_SET: TileSet = preload("res://assets/tilesets/greybox/greybox_tileset.tres")
const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")
const MUDBORN: PackedScene = preload("res://scenes/actors/enemies/mudborn/mudborn.tscn")
const SPEARMAN: PackedScene = preload("res://scenes/actors/enemies/gate_spearman/gate_spearman.tscn")
const FLOOR_Y: float = 320.0
const PLAYER_X: float = 240.0
## The wall: one tile wide (x 256..272), six tiles tall, between the player and the enemy.
const WALL_COLUMN: int = 16
const WALL_ROWS: Array[int] = [14, 15, 16, 17, 18, 19]

var _player: Player
var _tiles: TileMapLayer
var _enemy: Enemy


func _ready() -> void:
	Game.reset()
	_tiles = TileMapLayer.new()
	_tiles.tile_set = TILE_SET
	add_child(_tiles)
	for x: int in range(-20, 60):
		for y: int in range(20, 23):
			_tiles.set_cell(Vector2i(x, y), 0, Greybox.SOLID)
	_player = PLAYER_SCENE.instantiate() as Player
	add_child(_player)
	_run.call_deferred()


func _run() -> void:
	await _check_swing(&"short_sword", &"solid", 290.0, false, "the sword doesn't cut through a wall")
	await _check_swing(&"short_sword", &"none", 290.0, true, "the sword hits once the wall is gone")
	await _check_swing(&"short_sword", &"platform", 290.0, true, "one-way platforms don't block")
	await _check_swing(&"scythe_of_ninurta", &"solid", 300.0, false, "the scythe doesn't reap through a wall")
	await _check_swing(&"scythe_of_ninurta", &"none", 300.0, true, "the scythe hits once the wall is gone")
	await _check_spear()
	print("wall_block_test: done")


## Swings [param weapon] at a mudborn [param enemy_x] px along with a wall of
## [param wall] (&"solid", &"platform" or &"none") between them.
func _check_swing(weapon: StringName, wall: StringName, enemy_x: float, expect_hit: bool, check: String) -> void:
	await _arena(wall)
	if Game.stats.weapon.id != weapon:
		Game.equip(&"right_hand", weapon)
	_enemy = MUDBORN.instantiate() as Enemy
	add_child(_enemy)
	_enemy.global_position = Vector2(enemy_x, FLOOR_Y)
	_enemy.facing = -1
	_enemy.set_physics_process(false)
	_enemy.contact_hitbox.active = false
	await _frames(3)
	var hp_before: int = _enemy.health.health
	await _press(&"attack_right")
	# Sparks live a few frames, so watch for them during the swing.
	var sparked: bool = false
	for i: int in 45:
		await _frames(1)
		sparked = sparked or _wall_sparks() > 0
	var hit: bool = _enemy.health.health < hp_before
	var ok: bool = hit == expect_hit and (sparked if wall == &"solid" else true)
	_report(check, ok, "%s, wall %s: enemy hit=%s (HP %d -> %d), sparks on the wall=%s" % [
			weapon, wall, hit, hp_before, _enemy.health.health, sparked])


## The spearman's stab doesn't reach the player through a wall.
func _check_spear() -> void:
	await _arena(&"solid")
	_enemy = SPEARMAN.instantiate() as Enemy
	_enemy.set(&"forced_attack", 0)
	add_child(_enemy)
	_enemy.global_position = Vector2(PLAYER_X + 62.0, FLOOR_Y)
	_enemy.facing = -1
	_enemy.contact_hitbox.active = false
	var hp_before: int = Game.stats.hp
	var stabbed: bool = false
	for i: int in 90:
		await _frames(1)
		stabbed = stabbed or int(_enemy.get(&"phase")) == 2
	_report("the spear doesn't reach through a wall", stabbed and Game.stats.hp == hp_before,
			"stab thrown=%s, player HP %d -> %d" % [stabbed, hp_before, Game.stats.hp])


func _arena(wall: StringName) -> void:
	if is_instance_valid(_enemy):
		remove_child(_enemy)
		_enemy.queue_free()
	for y: int in WALL_ROWS:
		if wall == &"none":
			_tiles.erase_cell(Vector2i(WALL_COLUMN, y))
		else:
			_tiles.set_cell(Vector2i(WALL_COLUMN, y), 0, Greybox.SOLID if wall == &"solid" else Greybox.PLATFORM)
	Game.stats.hp = Game.stats.max_hp
	_player.respawn_at(Vector2(PLAYER_X, FLOOR_Y))
	_player.invulnerable_frames = 0
	_player.face(1)
	await _frames(4)


## HitSparks on the wall's face (x 250..272).
func _wall_sparks() -> int:
	var count: int = 0
	for node: Node in get_children():
		if node is HitSpark and (node as Node2D).global_position.x > 250.0 and (node as Node2D).global_position.x < 272.0:
			count += 1
	return count


func _press(action: StringName) -> void:
	Input.action_press(action)
	await _frames(1)
	Input.action_release(action)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _report(check: String, ok: bool, detail: String) -> void:
	print("VISUAL %s %s: %s (frame %d)" % ["PASS" if ok else "FAIL", check, detail, Engine.get_process_frames()])
