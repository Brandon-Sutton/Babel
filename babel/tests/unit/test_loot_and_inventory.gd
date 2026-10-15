extends GutTest
## INV-003 Inventory and INV-007 LootTable.


func _table(drops: PackedStringArray, weights: PackedInt32Array, amounts: PackedInt32Array) -> LootTable:
	var table: LootTable = LootTable.new()
	table.drops = drops
	table.weights = weights
	table.amounts = amounts
	return table


func test_roll_parses_kinds_and_amounts() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var only_item: LootTable = _table(["item:sappara"], [1], [1])
	var drop: LootTable.Drop = only_item.roll(rng)
	assert_eq(drop.kind, &"item")
	assert_eq(drop.item_id, &"sappara")
	var only_shekels: LootTable = _table(["shekels"], [1], [25])
	drop = only_shekels.roll(rng)
	assert_eq(drop.kind, &"shekels")
	assert_eq(drop.amount, 25)


func test_roll_follows_weights() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 1234
	var table: LootTable = _table(["embers", "shekels"], [90, 10], [1, 1])
	var embers: int = 0
	for i: int in 1000:
		if table.roll(rng).kind == &"embers":
			embers += 1
	assert_between(embers, 850, 950, "about 90% embers")


func test_luck_raises_item_odds() -> void:
	var table: LootTable = _table(["embers", "item:sappara"], [95, 5], [1, 1])
	var counts: Array[int] = [0, 0]
	for luck_index: int in 2:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = 99
		for i: int in 2000:
			if table.roll(rng, 0 if luck_index == 0 else 50).kind == &"item":
				counts[luck_index] += 1
	assert_gt(counts[1], counts[0], "luck 50 doubles item weight")


func test_empty_table_drops_nothing() -> void:
	assert_eq(LootTable.new().roll(RandomNumberGenerator.new()).kind, &"nothing")


func test_inventory_add_remove_count() -> void:
	var inventory: Inventory = Inventory.new()
	inventory.add(&"sappara")
	inventory.add(&"sappara", 2)
	assert_eq(inventory.count(&"sappara"), 3)
	assert_true(inventory.remove(&"sappara", 2))
	assert_eq(inventory.count(&"sappara"), 1)
	assert_false(inventory.remove(&"sappara", 5), "can't remove more than carried")
	assert_true(inventory.remove(&"sappara"))
	assert_false(inventory.ids().has(&"sappara"), "empty stacks disappear")


func test_inventory_round_trips_through_dict() -> void:
	var inventory: Inventory = Inventory.new()
	inventory.add(&"lapis_shield")
	inventory.add(&"seal_of_shamash", 2)
	var copy: Inventory = Inventory.new()
	copy.load_dict(inventory.to_dict())
	assert_eq(copy.count(&"seal_of_shamash"), 2)
	assert_eq(copy.count(&"lapis_shield"), 1)
