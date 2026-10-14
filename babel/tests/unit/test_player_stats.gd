extends GutTest
## RPG-001/002: experience curve, level-ups, derived attack/defense, HP and death.

var stats: PlayerStats


func before_each() -> void:
	stats = PlayerStats.new()
	stats.weapon = preload("res://data/weapons/short_sword.tres")


func test_xp_curve_grows_every_level() -> void:
	for level: int in range(1, 30):
		assert_gt(PlayerStats.xp_to_next(level + 1), PlayerStats.xp_to_next(level))
	assert_eq(PlayerStats.xp_total_for(1), 0)
	assert_eq(PlayerStats.xp_total_for(2), PlayerStats.xp_to_next(1))


func test_add_xp_levels_up_and_grows_stats() -> void:
	var leveled: Array[int] = []
	stats.leveled_up.connect(func(level: int) -> void: leveled.append(level))
	stats.add_xp(PlayerStats.xp_total_for(3))
	assert_eq(stats.level, 3)
	assert_eq(leveled, [2, 3] as Array[int])
	assert_eq(stats.strength, 8)
	assert_gt(stats.max_hp, 80)
	assert_eq(stats.hp, stats.max_hp, "level-up gains are added to current HP too")


func test_xp_to_next_level_counts_down() -> void:
	stats.add_xp(5)
	assert_eq(stats.xp_to_next_level(), PlayerStats.xp_to_next(1) - 5)


func test_attack_includes_weapon_and_defense_halves_con() -> void:
	assert_eq(stats.attack_power(), 6 + 5)
	assert_eq(stats.defense(), 3)


func test_take_damage_clamps_and_signals_death() -> void:
	var deaths: Array[int] = [0]
	stats.died.connect(func() -> void: deaths[0] += 1)
	assert_eq(stats.take_damage(30), 50)
	assert_eq(stats.take_damage(500), 0)
	assert_true(stats.is_dead())
	assert_eq(deaths[0], 1)
	assert_eq(stats.take_damage(5), 0, "no further damage once dead")
	assert_eq(deaths[0], 1)


func test_full_restore_refills() -> void:
	stats.take_damage(40)
	stats.spend_mp(10)
	stats.full_restore()
	assert_eq(stats.hp, stats.max_hp)
	assert_eq(stats.mp, stats.max_mp)
