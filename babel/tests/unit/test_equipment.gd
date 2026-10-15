extends GutTest
## INV-004 equipment rules and stat math, Game.equip, and SAV-001 save/load round trip.

const TEST_SLOT: int = 8

var stats: PlayerStats


func before_each() -> void:
	stats = PlayerStats.new()


func after_all() -> void:
	SaveSystem.delete_save(TEST_SLOT)
	Game.reset()


func _item(id: StringName) -> EquipmentData:
	return Game.item(id) as EquipmentData


func test_slots_only_accept_their_kind() -> void:
	assert_true(PlayerStats.fits(_item(&"sappara"), &"right_hand"))
	assert_false(PlayerStats.fits(_item(&"sappara"), &"head"))
	assert_true(PlayerStats.fits(_item(&"lapis_shield"), &"left_hand"))
	assert_true(PlayerStats.fits(_item(&"seal_of_shamash"), &"seal_2"))
	assert_eq(stats.equip(&"head", _item(&"sappara")), null, "refused, slot stays empty")
	assert_false(stats.equipped.has(&"head"))


func test_equipment_adds_attack_defense_and_bonuses() -> void:
	stats.equip(&"right_hand", _item(&"short_sword"))
	assert_eq(stats.attack_power(), 6 + 5)
	stats.equip(&"seal_1", _item(&"seal_of_nergal"))
	assert_eq(stats.attack_power(), 6 + 3 + 5, "STR +3 adds to attack")
	stats.equip(&"body", _item(&"masons_mail"))
	stats.equip(&"left_hand", _item(&"lapis_shield"))
	assert_eq(stats.defense(), 3 + 4 + 3)
	stats.equip(&"seal_2", _item(&"seal_of_shamash"))
	assert_eq(stats.total(&"luck"), 6 + 5)


func test_preview_does_not_change_equipment() -> void:
	stats.equip(&"right_hand", _item(&"short_sword"))
	var preview: Dictionary[StringName, int] = stats.preview(&"right_hand", _item(&"bronze_mace"))
	assert_eq(preview[&"attack"], 6 + 12)
	assert_eq(stats.weapon.id, &"short_sword", "still holding the sword")
	assert_eq(stats.preview(&"right_hand", null)[&"attack"], 6, "previewing removal")


func test_game_equip_swaps_with_inventory() -> void:
	Game.reset()
	assert_eq(Game.stats.weapon.id, &"short_sword")
	assert_true(Game.equip(&"right_hand", &"sappara"))
	assert_eq(Game.stats.weapon.id, &"sappara")
	assert_eq(Game.inventory.count(&"short_sword"), 1)
	assert_eq(Game.inventory.count(&"sappara"), 0)
	assert_false(Game.equip(&"right_hand", &"bronze_mace"), "not carried")
	assert_false(Game.equip(&"head", &"short_sword"), "wrong slot")
	assert_true(Game.equip(&"right_hand", &""), "unequip")
	assert_eq(Game.stats.weapon, null)
	assert_eq(Game.inventory.count(&"sappara"), 1)


func test_save_round_trip_restores_the_run() -> void:
	Game.reset()
	Game.stats.add_xp(PlayerStats.xp_total_for(3))
	Game.stats.add_shekels(42)
	Game.equip(&"seal_1", &"seal_of_shamash")
	Game.grant_ability(&"double_jump")
	Game.set_flag(&"test/flag")
	assert_eq(SaveSystem.save_game(TEST_SLOT, "res://scenes/world/rooms/test/sandbox_room.tscn", Vector2(96, 320)), OK)
	Game.reset()
	assert_eq(Game.stats.level, 1)
	var data: Dictionary = SaveSystem.load_game(TEST_SLOT)
	assert_false(data.is_empty())
	SaveSystem.apply_save(data)
	assert_eq(Game.stats.level, 3)
	assert_eq(Game.stats.shekels, 42)
	assert_eq((Game.stats.equipped[&"seal_1"] as EquipmentData).id, &"seal_of_shamash")
	assert_eq(Game.inventory.count(&"seal_of_shamash"), 0, "equipped, not carried")
	assert_true(Game.has_ability(&"double_jump"))
	assert_true(Game.is_flag(&"test/flag"))
	assert_eq(SaveSystem.saved_position(data), Vector2(96, 320))


func test_missing_or_corrupt_save_loads_empty() -> void:
	SaveSystem.delete_save(TEST_SLOT)
	assert_eq(SaveSystem.load_game(TEST_SLOT), {})
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SaveSystem.SAVE_DIR))
	var file: FileAccess = FileAccess.open(SaveSystem.slot_path(TEST_SLOT), FileAccess.WRITE)
	file.store_string("not json {")
	file.close()
	assert_eq(SaveSystem.load_game(TEST_SLOT), {})
	assert_push_error("not a valid save")
