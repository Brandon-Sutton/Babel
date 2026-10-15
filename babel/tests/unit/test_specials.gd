extends GutTest
## INV-016 equipment abilities and passives, SUB-001 Embers, SPL-002 learned Utterances,
## and that saves keep the carried Relic Arm and the learned spells.

const TEST_SLOT: int = 7


func before_each() -> void:
	Game.reset()


func after_all() -> void:
	SaveSystem.delete_save(TEST_SLOT)
	Game.reset()


func _item(id: StringName) -> EquipmentData:
	return Game.item(id) as EquipmentData


func test_equipment_ability_only_while_worn() -> void:
	assert_false(Game.has_ability(&"double_jump"))
	assert_true(Game.equip(&"mantle", &"feather_mantle"))
	assert_true(Game.has_ability(&"double_jump"), "the Feather Mantle grants it")
	assert_true(Game.equip(&"mantle", &"crimson_mantle"))
	assert_false(Game.has_ability(&"double_jump"), "gone once it is taken off")


func test_relic_ability_still_counts() -> void:
	Game.grant_ability(&"double_jump")
	assert_true(Game.has_ability(&"double_jump"))


func test_passives_add_up_across_items() -> void:
	var stats: PlayerStats = PlayerStats.new()
	assert_eq(stats.passive(&"mp_regen"), 0.0)
	stats.equip(&"seal_1", _item(&"lamp_of_ea"))
	stats.equip(&"seal_2", _item(&"lamp_of_ea"))
	assert_almost_eq(stats.passive(&"mp_regen"), 4.0, 0.001, "two Lamps of Ea stack")
	stats.equip(&"mantle", _item(&"courier_mantle"))
	assert_almost_eq(stats.passive(&"run_speed"), 0.25, 0.001)
	stats.equip(&"seal_2", null)
	assert_almost_eq(stats.passive(&"mp_regen"), 2.0, 0.001)


func test_embers_are_spent_only_when_there_are_enough() -> void:
	var stats: PlayerStats = Game.stats
	stats.embers = 2
	assert_true(stats.spend_embers(2))
	assert_eq(stats.embers, 0)
	assert_false(stats.spend_embers(1), "not enough left")
	assert_eq(stats.embers, 0)


func test_breath_restores_up_to_the_maximum() -> void:
	var stats: PlayerStats = Game.stats
	stats.mp = stats.max_mp - 1
	stats.restore_mp(5)
	assert_eq(stats.mp, stats.max_mp)


func test_starting_kit_has_a_relic_arm_and_a_spell() -> void:
	assert_eq(Game.stats.relic_arm.id, &"sling_stone")
	var known: Array[SpellData] = Game.known_spells()
	assert_eq(known.size(), 1)
	assert_eq(known[0].id, &"isatu")


func test_every_weapon_type_has_an_art() -> void:
	for id: StringName in [&"short_sword", &"sappara", &"bronze_mace", &"lion_greatsword", &"scythe_of_ninurta"]:
		var weapon: WeaponData = _item(id) as WeaponData
		assert_not_null(weapon.art, "%s has an art" % id)
		assert_eq(weapon.art.command, "B,F")


func test_save_keeps_relic_arm_and_spells() -> void:
	Game.stats.relic_arm = Game.item(&"clay_tablet") as RelicArmData
	Game.learn_spell(&"art_swift_thrust")
	assert_eq(SaveSystem.save_game(TEST_SLOT, "res://scenes/world/rooms/test/sandbox_room.tscn", Vector2.ZERO), OK)
	Game.reset()
	SaveSystem.apply_save(SaveSystem.load_game(TEST_SLOT))
	assert_eq(Game.stats.relic_arm.id, &"clay_tablet")
	assert_true(Game.spells.has(&"art_swift_thrust"))
	assert_true(Game.spells.has(&"isatu"))
