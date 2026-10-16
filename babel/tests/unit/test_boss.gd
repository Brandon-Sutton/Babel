extends GutTest
## BOSS-000 and BOSS-030: the pattern sequencer (weights, no repeats, phases, range,
## severed parts), phases from BossData, BossPart HP and severing, and severing on the
## Weeping Effigy itself (its patterns change, it pays bonus HP).

const EFFIGY: PackedScene = preload("res://scenes/actors/bosses/test_effigy/test_effigy.tscn")


func _pattern(id: StringName, weight: float, requires: StringName = &"", needs: StringName = &"",
		min_phase: int = 0, max_range: float = 0.0) -> BossPattern:
	var pattern: BossPattern = BossPattern.new()
	pattern.id = id
	pattern.weight = weight
	pattern.requires_part = requires
	pattern.needs_severed = needs
	pattern.min_phase = min_phase
	pattern.max_range = max_range
	return pattern


func _ids(patterns: Array[BossPattern]) -> Array[StringName]:
	var ids: Array[StringName] = []
	for pattern: BossPattern in patterns:
		ids.append(pattern.id)
	return ids


func test_sequencer_never_repeats_while_it_has_a_choice() -> void:
	var patterns: Array[BossPattern] = [_pattern(&"a", 10.0), _pattern(&"b", 1.0)]
	var sequencer: PatternSequencer = PatternSequencer.new(5)
	var previous: StringName = &""
	for i: int in 200:
		var picked: BossPattern = sequencer.pick(patterns, 0, {}, 100.0)
		assert_ne(picked.id, previous, "no pattern twice in a row")
		previous = picked.id
	var alone: Array[BossPattern] = [_pattern(&"only", 1.0)]
	assert_eq(sequencer.pick(alone, 0, {}, 100.0).id, &"only")
	assert_eq(sequencer.pick(alone, 0, {}, 100.0).id, &"only", "repeats when there is nothing else")


func test_sequencer_follows_the_weights() -> void:
	var patterns: Array[BossPattern] = [_pattern(&"heavy", 6.0), _pattern(&"light", 1.0), _pattern(&"other", 1.0)]
	var sequencer: PatternSequencer = PatternSequencer.new(11)
	var counts: Dictionary[StringName, int] = {}
	for i: int in 3000:
		var id: StringName = sequencer.pick(patterns, 0, {}, 100.0).id
		counts[id] = counts.get(id, 0) + 1
	# It can't follow itself, so it gets at most half the picks, but still the most.
	assert_gt(counts[&"heavy"], counts[&"light"] + 300, "the heavy pattern comes up most")
	assert_gt(counts[&"heavy"], counts[&"other"] + 300)
	assert_between(float(counts[&"light"]) / counts[&"other"], 0.8, 1.25, "equal weights, equal share")


func test_availability_honours_phase_range_and_parts() -> void:
	var patterns: Array[BossPattern] = [
		_pattern(&"slam", 1.0, &"arm"), _pattern(&"gaze", 1.0, &"", &"mask"),
		_pattern(&"late", 1.0, &"", &"", 1), _pattern(&"melee", 1.0, &"", &"", 0, 150.0),
	]
	var severed: Dictionary[StringName, bool] = {}
	assert_eq(_ids(PatternSequencer.available(patterns, 0, severed, 100.0)), [&"slam", &"melee"] as Array[StringName])
	assert_eq(_ids(PatternSequencer.available(patterns, 1, severed, 400.0)), [&"slam", &"late"] as Array[StringName],
			"phase 1 adds the late pattern; out of melee range")
	severed[&"arm"] = true
	severed[&"mask"] = true
	assert_eq(_ids(PatternSequencer.available(patterns, 0, severed, 100.0)), [&"gaze", &"melee"] as Array[StringName],
			"the arm's pattern is gone, the mask's loss unlocks the gaze")


func test_phases_from_health() -> void:
	var data: BossData = BossData.new()
	data.phase_thresholds = [0.66, 0.33]
	data.phase_speed = 1.5
	assert_eq(data.phase_for(1.0), 0)
	assert_eq(data.phase_for(0.66), 1)
	assert_eq(data.phase_for(0.5), 1)
	assert_eq(data.phase_for(0.2), 2)
	assert_almost_eq(data.speed_for(2), 2.25, 0.001)


func test_a_part_takes_damage_then_tears_off_once() -> void:
	var part: BossPart = BossPart.new()
	part.part_id = &"wing"
	part.max_hp = 30
	add_child_autofree(part)
	watch_signals(part)
	assert_false(part.take(20))
	assert_eq(part.hp, 10)
	assert_true(part.take(15), "the hit that reaches 0 tears it off")
	part.sever(320.0, 1.0)
	assert_true(part.is_severed())
	assert_signal_emit_count(part, "severed", 1)
	part.sever(320.0, 1.0)
	assert_false(part.take(50), "nothing more to take")
	assert_signal_emit_count(part, "severed", 1, "only once")


func test_effigy_data_is_complete() -> void:
	var data: BossData = Db.get_entry(&"test_effigy") as BossData
	assert_not_null(data)
	assert_eq(_ids(data.patterns), [&"slam", &"sweep", &"tears", &"gaze"] as Array[StringName])
	assert_not_null(Game.item(data.reward), "the reward exists")
	assert_false(data.title.is_empty())


func test_severing_the_effigys_arm_changes_its_fight() -> void:
	var effigy: Boss = EFFIGY.instantiate() as Boss
	add_child_autofree(effigy)
	await wait_physics_frames(1)
	assert_eq(effigy.parts.size(), 3, "two arms and the mask")
	var arm: BossPart = effigy.parts[&"arm_front"]
	var hp_before: int = effigy.health.health
	var hits: int = 0
	while not arm.is_severed() and hits < 40:
		var info: DamageInfo = DamageInfo.new()
		info.attack = 20
		effigy.hit_part(info, arm)
		effigy.health.invulnerable_frames_left = 0
		hits += 1
	assert_true(arm.is_severed(), "torn off after %d hits" % hits)
	assert_true(effigy.severed.get(&"arm_front", false))
	var lost: int = hp_before - effigy.health.health
	assert_gt(lost, arm.max_hp, "the arm's damage and the sever bonus both came off the boss")
	var left: Array[StringName] = _ids(PatternSequencer.available(effigy.boss_data().patterns, 0, effigy.severed, 100.0))
	assert_false(left.has(&"slam"), "no slam without the arm")
	assert_true(left.has(&"sweep"))
	assert_false(left.has(&"gaze"), "the mask is still on")
