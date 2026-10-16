extends GutTest
## NPC-004 buying, MAP-005 Surveyor's Maps and REL-009 the Wanderer's Cube: prices, too
## poor, already owned, what each kind of purchase gives, which cells a map reveals, and
## the cube's effect on lamp drops.

var _nabu: ShopData


func before_each() -> void:
	Game.reset()
	WorldMap.reset()
	_nabu = Db.get_entry(&"shop_nabu") as ShopData


func after_all() -> void:
	Game.reset()
	WorldMap.reset()


func test_nabu_sells_real_items_with_prices() -> void:
	assert_not_null(_nabu)
	assert_eq(_nabu.stock.size(), 6)
	for item_id: StringName in _nabu.stock:
		assert_not_null(Game.item(item_id), "%s exists" % item_id)
		assert_gt(Shop.price(_nabu, item_id), 0, "%s has a price" % item_id)
	assert_eq(Game.stats.shekels, Game.STARTING_SHEKELS, "a purse for the playtest")


func test_a_shop_can_override_a_price() -> void:
	var shop: ShopData = ShopData.new()
	shop.stock = [&"seal_of_nergal"]
	assert_eq(Shop.price(shop, &"seal_of_nergal"), 150, "the item's own price")
	shop.prices[&"seal_of_nergal"] = 99
	assert_eq(Shop.price(shop, &"seal_of_nergal"), 99)


func test_buying_gear_takes_shekels_and_can_repeat() -> void:
	var before: int = Game.stats.shekels
	assert_true(Shop.buy(_nabu, &"saffron_mantle"))
	assert_eq(Game.stats.shekels, before - 120)
	assert_eq(Game.inventory.count(&"saffron_mantle"), 1)
	assert_eq(Shop.status(_nabu, &"saffron_mantle"), &"ok", "gear can be bought again")
	assert_true(Shop.buy(_nabu, &"saffron_mantle"))
	assert_eq(Game.inventory.count(&"saffron_mantle"), 2)


func test_too_poor_buys_nothing() -> void:
	Game.stats.shekels = 100
	assert_eq(Shop.status(_nabu, &"gazelle_anklet"), &"poor")
	assert_false(Shop.buy(_nabu, &"gazelle_anklet"))
	assert_eq(Game.stats.shekels, 100)
	assert_false(Game.has_ability(&"double_jump"))


func test_a_relic_grants_its_ability_once() -> void:
	# The Feather Mantle gives the double jump too, but wearing it doesn't own the relic.
	Game.equip(&"mantle", &"feather_mantle")
	assert_eq(Shop.status(_nabu, &"gazelle_anklet"), &"ok")
	assert_true(Shop.buy(_nabu, &"gazelle_anklet"))
	assert_true(Game.owns_relic(Game.item(&"gazelle_anklet") as RelicData))
	assert_eq(Shop.status(_nabu, &"gazelle_anklet"), &"owned")
	assert_false(Shop.buy(_nabu, &"gazelle_anklet"), "bought once")
	assert_eq(Game.inventory.count(&"gazelle_anklet"), 0, "relics don't go in the bag")


func test_a_map_reveals_its_section_only() -> void:
	WorldMap.discover_cell(Vector2i(0, 0))
	assert_false(WorldMap.is_revealed(Vector2i(1, 0)), "nothing revealed without a map")
	assert_eq(MapScreen.cell_state(Vector2i(1, 0)), &"unknown", "unvisited and unmapped: not drawn")
	assert_true(Shop.buy(_nabu, &"surveyor_map_west"))
	assert_eq(Shop.status(_nabu, &"surveyor_map_west"), &"owned")
	assert_eq(MapScreen.cell_state(Vector2i(0, 0)), &"explored", "explored stays highlighted")
	assert_eq(MapScreen.cell_state(Vector2i(1, 0)), &"unexplored", "revealed, shown dim")
	assert_eq(MapScreen.cell_state(Vector2i(2, 0)), &"unknown", "outside the West Hall")
	assert_true(Shop.buy(_nabu, &"surveyor_map_east"))
	assert_eq(MapScreen.cell_state(Vector2i(2, 0)), &"unexplored")
	assert_eq(MapScreen.cell_state(Vector2i(3, 0)), &"hidden", "secret rooms stay secret")
	assert_eq(MapScreen.cell_state(Vector2i(2, 1)), &"hidden")


func test_map_progress_counts_the_section() -> void:
	var west: MapData = Game.item(&"surveyor_map_west") as MapData
	assert_eq(Shop.map_progress(west), Vector2i(2, 0))
	WorldMap.discover_cell(Vector2i(0, 0))
	assert_eq(Shop.map_progress(west), Vector2i(2, 1), "2 screens, 1 explored")


func test_the_cube_doubles_lamp_item_odds() -> void:
	var lamp: LootTable = load("res://data/loot/votive_lamp.tres") as LootTable
	var counts: Array[int] = [0, 0]
	for run: int in 2:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = 321
		for i: int in 4000:
			if lamp.roll(rng, 0, 1.0 if run == 0 else 2.0).kind == &"item":
				counts[run] += 1
	assert_gt(counts[0], 0)
	assert_between(float(counts[1]) / counts[0], 1.6, 2.4, "about twice as many items")
	assert_true(Shop.buy(_nabu, &"wanderers_cube"))
	assert_true(Game.has_ability(&"lamp_items"), "the lamps check this")
