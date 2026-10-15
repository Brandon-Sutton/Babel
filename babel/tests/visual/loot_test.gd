extends Node2D
## Scripted check of enemy loot (INV-013) with the real player and real enemies: a kill
## rolls the enemy's loot table and the drop pops out where it died, dropped gear stays
## while Embers blink out, collecting gear puts it in the bag, and every enemy's gear can
## be equipped and is visible on Elam. Drops are made repeatable with Enemy.seed_loot.
## Logs "VISUAL PASS/FAIL". Needs a real window: run it via tools/capture.sh (about
## 1300 frames).

const Greybox := preload("res://tools/builders/build_greybox_tileset.gd")
const TILE_SET: TileSet = preload("res://assets/tilesets/greybox/greybox_tileset.tres")
const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")
const MUDBORN: PackedScene = preload("res://scenes/actors/enemies/mudborn/mudborn.tscn")
const SPEARMAN: PackedScene = preload("res://scenes/actors/enemies/gate_spearman/gate_spearman.tscn")
const MASK: PackedScene = preload("res://scenes/actors/enemies/humbaba_mask/humbaba_mask.tscn")
const FLOOR_Y: float = 320.0
const START_X: float = 300.0

var _player: Player


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
	_player.god_mode = true
	var gear: Pickup = await _check_kill_drops()
	await _check_gear_stays(gear)
	await _check_collect_and_wear(gear)
	await _check_every_enemy()
	await _showcase()
	print("loot_test: done")


## A Mudborn killed with the sword rolls its table and the gear pops out where it fell.
func _check_kill_drops() -> Pickup:
	await _reset()
	var enemy: Enemy = MUDBORN.instantiate() as Enemy
	add_child(enemy)
	enemy.global_position = Vector2(START_X + 40.0, FLOOR_Y)
	_seed_for(enemy.data.loot, &"riverclay_mail")
	var died_at: float = enemy.global_position.x
	for i: int in 16 * 24:
		if not enemy.health.is_alive():
			break
		died_at = enemy.global_position.x
		if i % 24 == 0:
			_press(&"attack_right")
		await _frames(1)
	# Out of the pickup's magnet range before it can be collected.
	_player.respawn_at(Vector2(START_X - 250.0, FLOOR_Y))
	await _frames(40)
	var items: Array[Pickup] = _pickups(&"item")
	var gear: Pickup = items[0] if items.size() == 1 else null
	_report("a kill drops from the enemy's loot table", gear != null and gear.item_id == &"riverclay_mail"
			and absf(gear.global_position.x - died_at) < 80.0,
			"item drops %d (%s) at %.0f, enemy died at %.0f" % [items.size(),
			gear.item_id if gear != null else &"-", gear.global_position.x if gear != null else 0.0, died_at])
	return gear


## Gear stays on the floor; Embers dropped beside it blink out after 10 s.
func _check_gear_stays(gear: Pickup) -> void:
	_player.respawn_at(Vector2(START_X - 250.0, FLOOR_Y))
	var embers: LootTable.Drop = LootTable.Drop.new()
	embers.kind = &"embers"
	embers.amount = 1
	if gear != null:
		Pickup.spawn(self, gear.global_position + Vector2(0, -10), embers)
	await _frames(Pickup.LIFETIME_FRAMES + 20)
	var stayed: bool = is_instance_valid(gear) and gear.visible
	var embers_left: int = _pickups(&"embers").size()
	_report("dropped gear stays, Embers blink out", stayed and embers_left == 0,
			"gear still there=%s after %d frames, Embers left %d" % [stayed, Pickup.LIFETIME_FRAMES + 20, embers_left])


## Walking onto the gear puts it in the bag; worn, Riverclay Mail dyes the plates.
func _check_collect_and_wear(gear: Pickup) -> void:
	if is_instance_valid(gear):
		_player.respawn_at(Vector2(gear.global_position.x, FLOOR_Y))
	await _frames(20)
	var carried: int = Game.inventory.count(&"riverclay_mail")
	var equipped: bool = Game.equip(&"body", &"riverclay_mail")
	await _frames(2)
	var item: EquipmentData = Game.item(&"riverclay_mail") as EquipmentData
	var dye: ShaderMaterial = _player.sprite.material as ShaderMaterial
	var mid: Vector3 = dye.get_shader_parameter(&"plates_mid") if dye != null else Vector3.ZERO
	var dyed: bool = dye != null and dye.get_shader_parameter(&"dye_plates") \
			and mid.is_equal_approx(Vector3(item.dye_ramp[1].r, item.dye_ramp[1].g, item.dye_ramp[1].b))
	_report("collected gear is carried and worn", carried == 1 and not is_instance_valid(gear) and equipped and dyed,
			"in the bag %d, pickup gone=%s, equipped=%s, plates dyed=%s" % [carried, not is_instance_valid(gear),
			equipped, dyed])


## Each enemy's gear: forced by the seed, dropped on death, collected, equipped, visible.
func _check_every_enemy() -> void:
	var cases: Array[Array] = [
		[MUDBORN, &"potsherd_seal", &"seal_1"],
		[SPEARMAN, &"gate_guard_helm", &"head"],
		[SPEARMAN, &"watchmans_mantle", &"mantle"],
		[MASK, &"seal_of_humbaba", &"seal_2"],
	]
	for entry: Array in cases:
		await _reset()
		var enemy: Enemy = (entry[0] as PackedScene).instantiate() as Enemy
		add_child(enemy)
		# Far enough that the drop isn't pulled in before it is checked.
		enemy.global_position = Vector2(START_X + 160.0, FLOOR_Y - (60.0 if entry[0] == MASK else 0.0))
		var enemy_name: String = enemy.data.display_name
		var id: StringName = entry[1]
		_seed_for(enemy.data.loot, id)
		enemy.health.apply_damage(enemy.health.health, DamageInfo.new())
		await _frames(40)
		var found: Pickup = null
		for pickup: Pickup in _pickups(&"item"):
			if pickup.item_id == id:
				found = pickup
		# Checked before collecting: a freed pickup compares equal to null.
		var dropped: bool = found != null
		if dropped:
			_player.respawn_at(Vector2(found.global_position.x, FLOOR_Y))
		await _frames(20)
		var carried: bool = Game.inventory.count(id) > 0
		var equipped: bool = Game.equip(entry[2], id)
		await _frames(2)
		var shown: bool = _is_shown(Game.item(id) as EquipmentData)
		_report("%s drops %s, worn and visible" % [enemy_name, id],
				dropped and carried and equipped and shown,
				"dropped=%s, carried=%s, equipped=%s, visible=%s" % [dropped, carried, equipped, shown])


## Elam in all the found gear, for the eye; the Watchman's Mantle heals 1 HP in 2 s.
func _showcase() -> void:
	await _reset()
	Game.stats.hp = Game.stats.max_hp - 10
	var hp: int = Game.stats.hp
	await _frames(120)
	_report("Watchman's Mantle: HP regenerates", Game.stats.hp == hp + 1,
			"HP %d -> %d in 2 s (want +1)" % [hp, Game.stats.hp])
	Input.action_press(&"move_right")
	await _frames(40)
	Input.action_release(&"move_right")
	await _frames(30)


# --- Helpers ------------------------------------------------------------------------

## Seeds the shared loot generator so the next roll of [param table] drops [param id].
func _seed_for(table: LootTable, id: StringName) -> void:
	var luck: int = Game.stats.total(&"luck")
	for value: int in range(1, 5000):
		var probe: RandomNumberGenerator = RandomNumberGenerator.new()
		probe.seed = value
		if table.roll(probe, luck).item_id == id:
			Enemy.seed_loot(value)
			return
	push_error("loot_test: no seed drops %s" % id)


## True if [param item] shows on Elam: a visible worn sprite, or its dye is on.
func _is_shown(item: EquipmentData) -> bool:
	if item.worn != null:
		for child: Node in _player.equipment_rig.get_children():
			var sprite: Sprite2D = child as Sprite2D
			if sprite != null and sprite.visible and sprite.texture == item.worn.texture:
				return true
		return false
	var dye: ShaderMaterial = _player.sprite.material as ShaderMaterial
	return dye != null and dye.get_shader_parameter(StringName("dye_" + String(item.dye_material)))


func _pickups(kind: StringName) -> Array[Pickup]:
	var found: Array[Pickup] = []
	for node: Node in get_children():
		if node is Pickup and (node as Pickup).kind == kind and not node.is_queued_for_deletion():
			found.append(node as Pickup)
	return found


func _reset() -> void:
	for node: Node in get_children():
		if node is Enemy or node is Pickup:
			remove_child(node)
			node.queue_free()
	Game.stats.full_restore()
	_player.respawn_at(Vector2(START_X, FLOOR_Y))
	_player.face(1)
	await _frames(6)


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
