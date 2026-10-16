extends GutTest
## INV-013 enemy loot: every table is well formed and names real items, every enemy can
## drop gear, the drop rates come out as weighted, and every piece of equipment is
## visible on Elam (GDD §6.7).

const LOOT_DIR: String = "res://data/loot"


func _tables() -> Dictionary[String, LootTable]:
	var tables: Dictionary[String, LootTable] = {}
	for path: String in FileScan.list_files(LOOT_DIR, [".tres"]):
		tables[path] = load(path) as LootTable
	return tables


func _enemies() -> Array[EnemyData]:
	var enemies: Array[EnemyData] = []
	for id: StringName in Db.ids():
		# Bosses drop a guaranteed reward instead of rolling loot (BOSS-000).
		if Db.get_entry(id) is EnemyData and not Db.get_entry(id) is BossData:
			enemies.append(Db.get_entry(id) as EnemyData)
	return enemies


func test_tables_are_well_formed_and_name_real_items() -> void:
	var tables: Dictionary[String, LootTable] = _tables()
	assert_gt(tables.size(), 3, "the lamp's table and one per enemy")
	for path: String in tables:
		var table: LootTable = tables[path]
		assert_not_null(table, path)
		assert_eq(table.weights.size(), table.drops.size(), "%s: a weight per drop" % path)
		assert_eq(table.amounts.size(), table.drops.size(), "%s: an amount per drop" % path)
		for entry: String in table.drops:
			if entry.begins_with("item:"):
				var id: StringName = StringName(entry.trim_prefix("item:"))
				assert_true(Db.get_entry(id) is ItemData, "%s: %s is an item" % [path, id])
			else:
				assert_has(["nothing", "embers", "shekels"], entry, "%s: known drop kind" % path)


func test_every_enemy_can_drop_gear() -> void:
	var enemies: Array[EnemyData] = _enemies()
	assert_eq(enemies.size(), 3)
	for enemy: EnemyData in enemies:
		assert_not_null(enemy.loot, "%s has a loot table" % enemy.id)
		if enemy.loot == null:
			continue
		var gear: int = 0
		for entry: String in enemy.loot.drops:
			if entry.begins_with("item:") and Db.get_entry(StringName(entry.trim_prefix("item:"))) is EquipmentData:
				gear += 1
		assert_gt(gear, 0, "%s drops gear" % enemy.id)


func test_drop_only_gear_is_not_in_the_starting_bag() -> void:
	for id: StringName in [&"potsherd_seal", &"riverclay_mail", &"gate_guard_helm", &"watchmans_mantle", &"seal_of_humbaba"]:
		assert_true(Db.get_entry(id) is EquipmentData, "%s exists" % id)
		assert_false(Game.STARTING_INVENTORY.has(id), "%s is found, not given" % id)


func test_mudborn_rates_follow_the_weights() -> void:
	var table: LootTable = (Db.get_entry(&"mudborn") as EnemyData).loot
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 2026
	var counts: Dictionary[StringName, int] = {}
	for i: int in 4000:
		var drop: LootTable.Drop = table.roll(rng)
		var key: StringName = drop.item_id if drop.kind == &"item" else drop.kind
		counts[key] = counts.get(key, 0) + 1
	assert_between(counts.get(&"potsherd_seal", 0), 320, 480, "common gear about 1 in 10")
	assert_between(counts.get(&"riverclay_mail", 0), 110, 210, "rare gear about 1 in 25")
	assert_between(counts.get(&"nothing", 0), 1450, 1750, "nothing about 40%")


func test_every_equipment_item_is_visible() -> void:
	for id: StringName in Db.ids():
		var item: EquipmentData = Db.get_entry(id) as EquipmentData
		if item == null:
			continue
		var dyed: bool = not item.dye_material.is_empty() and item.dye_ramp.size() >= 3
		assert_true(item.worn != null or dyed, "%s has a worn sprite or a dye" % id)


func test_seeded_rolls_repeat() -> void:
	var table: LootTable = (Db.get_entry(&"gate_spearman") as EnemyData).loot
	var first: PackedStringArray = []
	var second: PackedStringArray = []
	for run: int in 2:
		Enemy.seed_loot(77)
		for i: int in 20:
			var drop: LootTable.Drop = table.roll(Enemy.loot_rng())
			(first if run == 0 else second).append("%s:%s" % [drop.kind, drop.item_id])
	assert_eq(first, second, "Enemy.seed_loot makes drops repeatable")
