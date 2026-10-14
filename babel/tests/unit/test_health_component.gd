extends GutTest
## CBT-002: damage, clamping, invulnerability window, death signal.

var health: HealthComponent


func before_each() -> void:
	health = HealthComponent.new()
	health.reset(20)


func after_each() -> void:
	health.free()


func test_damage_reduces_and_clamps() -> void:
	assert_true(health.apply_damage(5))
	assert_eq(health.health, 15)
	health.apply_damage(100)
	assert_eq(health.health, 0)
	assert_false(health.is_alive())


func test_invulnerability_blocks_until_ticked_out() -> void:
	health.apply_damage(1, null, 2)
	assert_false(health.apply_damage(1), "blocked while invulnerable")
	health.tick()
	assert_false(health.apply_damage(1), "still one frame left")
	health.tick()
	assert_true(health.apply_damage(1))
	assert_eq(health.health, 18)


func test_died_emits_once() -> void:
	var deaths: Array[int] = [0]
	health.died.connect(func() -> void: deaths[0] += 1)
	health.apply_damage(25)
	assert_false(health.apply_damage(5), "no damage once dead")
	assert_eq(deaths[0], 1)


func test_heal_caps_at_max() -> void:
	health.apply_damage(10)
	health.heal(50)
	assert_eq(health.health, 20)
