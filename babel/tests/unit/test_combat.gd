extends GutTest
## CBT-003: damage formula and critical chance.


func test_damage_is_attack_minus_half_defense() -> void:
	assert_eq(Combat.damage(11, 2), 10)
	assert_eq(Combat.damage(20, 10), 15)


func test_damage_rounds_half_up() -> void:
	assert_eq(Combat.damage(8, 3), 7, "8 - 1.5 = 6.5 rounds to 7")


func test_damage_is_never_below_one() -> void:
	assert_eq(Combat.damage(1, 50), 1)
	assert_eq(Combat.damage(0, 0), 1)


func test_critical_multiplies_damage() -> void:
	assert_eq(Combat.damage(11, 2, true), 15, "10 x 1.5")


func test_crit_chance_scales_with_luck_and_caps() -> void:
	assert_almost_eq(Combat.crit_chance(6), 0.03, 0.0001)
	assert_eq(Combat.crit_chance(0), 0.0)
	assert_eq(Combat.crit_chance(500), Combat.CRIT_CAP)
