extends Node2D
## Scripted check of crouching (PLR-006/008) and the Gate Spearman moveset (ENM-007):
## the crouch holds while Down is held, the crouching slash plays its own art, hits a
## low enemy and returns to the held crouch; the stab hits standing and crouching alike
## but a jump clears it, crouching ducks the fireball, jumping clears the sweep, a jump in close draws the anti-air, the sword cuts a
## fireball, and the leap lands its plunge on the player. Logs "VISUAL PASS/FAIL"
## lines. Needs a real window: run it via tools/capture.sh (about 1500 frames).

const Greybox := preload("res://tools/builders/build_greybox_tileset.gd")
const TILE_SET: TileSet = preload("res://assets/tilesets/greybox/greybox_tileset.tres")
const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")
const SPEARMAN: PackedScene = preload("res://scenes/actors/enemies/gate_spearman/gate_spearman.tscn")
const MUDBORN: PackedScene = preload("res://scenes/actors/enemies/mudborn/mudborn.tscn")
const FLOOR_Y: float = 320.0
const SPEARMAN_X: float = 200.0
## Values of the spearman script's Attack enum (the script has no class_name).
const NONE: int = -1
const STAB: int = 0
const SWEEP: int = 1
const ANTI_AIR: int = 2
const FIREBALL: int = 3
const LEAP: int = 4

var _player: Player
var _spearman: Enemy
## Attacks whose spear hitbox connected since the last _arena() call.
var _spear_hits: Array[int] = []


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
	_player.respawn_at(Vector2(120, FLOOR_Y))
	_run.call_deferred()


func _run() -> void:
	await _frames(10)
	await _check_crouch()
	await _check_crouch_attack()
	await _check_attack(STAB, 60.0, &"crouch", true, "the stab hits a crouching player")
	await _check_attack(STAB, 60.0, &"jump", false, "jumping clears the stab")
	await _check_attack(STAB, 60.0, &"stand", true, "the stab hits a standing player")
	await _check_attack(SWEEP, 60.0, &"stand", true, "the sweep hits a standing player")
	await _check_attack(SWEEP, 60.0, &"jump", false, "jumping clears the sweep")
	await _check_anti_air()
	await _check_attack(FIREBALL, 220.0, &"stand", true, "the fireball hits a standing player")
	await _check_attack(FIREBALL, 220.0, &"crouch", false, "the fireball flies over a crouch")
	await _check_fireball_cut()
	await _check_leap()
	print("spearman_test: done")


## Holding Down keeps the crouch: the state stays Crouch and the pose stops changing.
func _check_crouch() -> void:
	Input.action_press(&"move_down")
	await _frames(20)
	var held: Vector2i = _player.sprite.frame_coords
	var steady: bool = true
	for i: int in 100:
		await _frames(1)
		if _player.machine.current_name() != &"Crouch" or _player.sprite.frame_coords != held:
			steady = false
	Input.action_release(&"move_down")
	_report("crouch holds while Down is held", steady,
			"state %s, pose %s held for 100 frames=%s" % [_player.machine.current_name(), held, steady])
	await _frames(10)


## A crouching slash plays crouch_attack, hits a low enemy and returns to the held crouch.
func _check_crouch_attack() -> void:
	var mudborn: Enemy = MUDBORN.instantiate() as Enemy
	add_child(mudborn)
	mudborn.global_position = _player.global_position + Vector2(40, 0)
	mudborn.contact_hitbox.active = false
	var hp_before: int = mudborn.health.health
	Input.action_press(&"move_down")
	await _frames(12)
	var crouch_pose: Vector2i = _player.sprite.frame_coords
	await _press(&"attack_right")
	await _frames(3)
	var art: StringName = _player.animation_player.assigned_animation
	var low: bool = _player.crouching
	# Wait out the swing (hit-stop on the enemy stretches it), then one more frame.
	for i: int in 90:
		if _player.machine.current_name() != &"Attack":
			break
		await _frames(1)
	await _frames(1)
	var hit: bool = not is_instance_valid(mudborn) or mudborn.health.health < hp_before
	var back_down: bool = _player.machine.current_name() == &"Crouch" and _player.sprite.frame_coords == crouch_pose
	Input.action_release(&"move_down")
	_report("crouching slash", art == &"crouch_attack" and low and hit and back_down,
			"art %s, crouched=%s, low enemy hit=%s, back in the held crouch=%s" % [art, low, hit, back_down])
	if is_instance_valid(mudborn):
		mudborn.queue_free()
	await _frames(10)


## Forces [param attack] with the player [param gap] px away doing [param stance]
## (stand, crouch or jump), then checks whether the player took damage.
func _check_attack(attack: int, gap: float, stance: StringName, expect_hit: bool, check: String) -> void:
	await _arena(gap, attack)
	if stance == &"crouch":
		Input.action_press(&"move_down")
	var hp_before: int = Game.stats.hp
	var saw_attack: bool = false
	for i: int in 110:
		await _frames(1)
		saw_attack = saw_attack or int(_spearman.get(&"attack")) == attack
		if stance == &"jump" and int(_spearman.get(&"phase")) == 1 and int(_spearman.get(&"_timer")) == 10:
			Input.action_press(&"jump")
		elif stance == &"jump":
			Input.action_release(&"jump")
		if Game.stats.hp < hp_before:
			break
	Input.action_release(&"move_down")
	Input.action_release(&"jump")
	var hit: bool = Game.stats.hp < hp_before
	_report(check, saw_attack and hit == expect_hit,
			"attack seen=%s, player hit=%s (HP %d -> %d)" % [saw_attack, hit, hp_before, Game.stats.hp])


## Jumping in close draws the anti-air (chosen by the AI, not forced) and it connects.
func _check_anti_air() -> void:
	await _arena(100.0, NONE)
	var hp_before: int = Game.stats.hp
	Input.action_press(&"jump")
	Input.action_press(&"move_left")
	var chosen: bool = false
	for i: int in 60:
		await _frames(1)
		chosen = chosen or int(_spearman.get(&"attack")) == ANTI_AIR
		if i == 20:
			Input.action_release(&"jump")
		if _player.global_position.x <= _spearman.global_position.x + 40.0:
			Input.action_release(&"move_left")
	Input.action_release(&"jump")
	Input.action_release(&"move_left")
	_report("jumping in draws the anti-air", chosen and _spear_hits.has(ANTI_AIR),
			"anti-air chosen=%s, spear connected=%s (HP %d -> %d)" % [
			chosen, _spear_hits.has(ANTI_AIR), hp_before, Game.stats.hp])


## A sword stroke timed against an incoming fireball destroys it before it lands.
func _check_fireball_cut() -> void:
	await _arena(220.0, FIREBALL)
	var hp_before: int = Game.stats.hp
	var seen: bool = false
	var swung: bool = false
	for i: int in 140:
		await _frames(1)
		var fireball: Fireball = _find_fireball()
		if fireball == null and seen:
			break
		if fireball != null:
			seen = true
			if not swung and absf(fireball.global_position.x - _player.global_position.x) < 50.0:
				swung = true
				await _press(&"attack_right")
	var gone: bool = _find_fireball() == null
	_report("the sword cuts a fireball", seen and swung and gone and Game.stats.hp == hp_before,
			"fireball seen=%s, swung=%s, destroyed=%s, HP %d -> %d" % [seen, swung, gone, hp_before, Game.stats.hp])


## The leap rises toward the player, plunges, lands near them and the plunge connects.
func _check_leap() -> void:
	await _arena(160.0, LEAP)
	var start_x: float = _spearman.global_position.x
	var peak: float = 0.0
	var landed: bool = false
	for i: int in 150:
		await _frames(1)
		peak = maxf(peak, FLOOR_Y - _spearman.global_position.y)
		if int(_spearman.get(&"attack")) == LEAP and int(_spearman.get(&"phase")) == 4:
			landed = true
			break
	var travelled: float = _spearman.global_position.x - start_x
	_report("the leap plunges onto the player", landed and peak > 80.0 and _spear_hits.has(LEAP),
			"rose %d px, travelled %d px, landed=%s, plunge connected=%s" % [
			peak, travelled, landed, _spear_hits.has(LEAP)])
	await _frames(30)


## Fresh spearman facing the player, who stands [param gap] px to its right at full HP.
## [param first_attack] is forced before the spearman can choose (NONE lets it choose).
func _arena(gap: float, first_attack: int) -> void:
	# Detach the previous spearman and fireballs now: queue_free alone would leave their
	# hitboxes running for the rest of this frame.
	if is_instance_valid(_spearman):
		remove_child(_spearman)
		_spearman.queue_free()
	for node: Node in get_children():
		if node is Fireball:
			remove_child(node)
			node.queue_free()
	_spear_hits.clear()
	Game.stats.hp = Game.stats.max_hp
	_player.respawn_at(Vector2(SPEARMAN_X + gap, FLOOR_Y))
	_player.invulnerable_frames = 0
	_player.face(-1)
	await _frames(2)
	_spearman = SPEARMAN.instantiate() as Enemy
	_spearman.set(&"forced_attack", first_attack)
	add_child(_spearman)
	_spearman.global_position = Vector2(SPEARMAN_X, FLOOR_Y)
	_spearman.facing = 1
	var spear: Hitbox = _spearman.get_node(^"%SpearHitbox") as Hitbox
	spear.hit_landed.connect(func(_hurtbox: Hurtbox, _info: DamageInfo) -> void:
		_spear_hits.append(int(_spearman.get(&"attack"))))
	await _frames(2)


func _find_fireball() -> Fireball:
	for node: Node in get_children():
		if node is Fireball and not node.is_queued_for_deletion():
			return node as Fireball
	return null


func _press(action: StringName) -> void:
	Input.action_press(action)
	await _frames(1)
	Input.action_release(action)


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _report(check: String, ok: bool, detail: String) -> void:
	print("VISUAL %s %s: %s (frame %d)" % ["PASS" if ok else "FAIL", check, detail, Engine.get_process_frames()])
