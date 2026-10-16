@abstract
class_name Boss
extends Enemy
## Base for every boss (BOSS-000), on top of Enemy (hits, flash, damage numbers,
## contact damage). Stats and fight design come from [member data] as a BossData.
##
## The boss stands still until its BossArena announces it (name card, HP bar) and then
## begins the fight. It then loops: rest, pick a pattern with a PatternSequencer
## (weighted, never twice in a row, honouring the phase, the range and severed parts),
## play it, rest. Crossing a phase threshold makes it flinch and play faster. Severable
## BossParts (BOSS-030) anywhere under it are found on ready: their hits damage the part
## and the boss, and tearing one off costs the boss bonus HP and a flinch, and changes
## which patterns it has. Death plays a sequence, drops the guaranteed reward and emits
## Events.boss_defeated.
##
## A subclass performs the patterns: _start_pattern(), _update_pattern() (return true
## when done) and _cancel_pattern(); it may react in _on_phase_changed() and
## _on_part_severed().

## Emitted when a new phase begins.
signal phase_changed(phase: int)
## Emitted when a part is torn off.
signal part_severed(part_id: StringName)
## Emitted when the death sequence reaches the reward drop.
signal defeated

const FLINCH_FRAMES: int = 36
const DEATH_SEQUENCE_FRAMES: int = 150
const BURST_EVERY: int = 7
const TELEGRAPH: Color = Color("fbe69b")

## The area bursts come from while it dies, relative to its feet.
@export var body_rect: Rect2 = Rect2(-40, -140, 80, 140)

## True once the fight has begun.
var started: bool = false
var phase: int = 0
## Parts by id.
var parts: Dictionary[StringName, BossPart] = {}
## Ids of the parts torn off.
var severed: Dictionary[StringName, bool] = {}
## The pattern being played, or null while resting.
var current: BossPattern
var sequencer: PatternSequencer = PatternSequencer.new()
## Frames into the current pattern.
var pattern_frame: int = 0

var _rest_frames: int = 0
var _flinch_frames: int = 0
var _announced: bool = false


func _ready() -> void:
	super._ready()
	_collect_parts(self)
	_rest_frames = boss_data().rest_frames


## The data as a BossData.
func boss_data() -> BossData:
	return data as BossData


## Shows the name card and HP bar (Events.boss_started) before the fight begins.
func announce() -> void:
	if _announced:
		return
	_announced = true
	Events.boss_started.emit(self)


## Starts the fight.
func begin() -> void:
	announce()
	started = true


## Patterns that could be chosen right now (for tests and debugging).
func available_patterns() -> Array[BossPattern]:
	return PatternSequencer.available(boss_data().patterns, phase, severed, _player_distance())


## Speed of patterns and rests in the current phase.
func speed() -> float:
	return boss_data().speed_for(phase)


## Frames scaled by the phase speed (wind-ups and rests get shorter each phase).
func scaled(frames: int) -> int:
	return maxi(1, roundi(frames / speed()))


func _collect_parts(node: Node) -> void:
	for child: Node in node.get_children():
		var part: BossPart = child as BossPart
		if part != null:
			parts[part.part_id] = part
			part.hurtbox().owner_node = self
			part.hurtbox().handler = hit_part.bind(part)
		_collect_parts(child)


## Hurtbox handler of [param part]: the part takes the damage, and so does the boss (its
## own invulnerability frames still apply). Tearing the part off is handled here.
func hit_part(info: DamageInfo, part: BossPart) -> bool:
	if is_dying() or part.is_severed():
		return false
	var amount: int = Combat.damage(info.attack, data.defense, info.critical)
	var accepted: bool = _on_hit(info)
	if part.take(amount):
		_sever(part)
	return accepted or amount > 0


func _sever(part: BossPart) -> void:
	# Flung forward, toward Elam, where it can be seen.
	part.sever(global_position.y, float(facing))
	severed[part.part_id] = true
	GameCamera.shake(get_tree(), 4.0, 16)
	HitStop.trigger(get_tree(), 6)
	if part.sever_damage > 0 and health.is_alive():
		health.invulnerable_frames_left = 0
		health.apply_damage(part.sever_damage)
		DamageNumber.spawn(get_tree(), part.global_position + Vector2(0, -12), part.sever_damage, Color("ef6a6a"), true)
	_flinch()
	part_severed.emit(part.part_id)
	_on_part_severed(part)


func _flinch() -> void:
	if current != null:
		_cancel_pattern(current.id)
		current = null
	_flinch_frames = FLINCH_FRAMES
	_rest_frames = scaled(boss_data().rest_frames)


func _on_damaged(_info: DamageInfo, _staggered: bool) -> void:
	var next: int = boss_data().phase_for(float(health.health) / maxi(1, health.max_health))
	if next > phase and health.is_alive():
		phase = next
		_flinch()
		phase_changed.emit(phase)
		_on_phase_changed(phase)


func _behave(_delta: float) -> void:
	velocity.x = 0.0
	queue_redraw()
	if not started:
		return
	if _flinch_frames > 0:
		_flinch_frames -= 1
		set_flash(0.5 * float(_flinch_frames % 6 < 3), Color("ef6a6a"))
		if _flinch_frames == 0:
			set_flash(0.0)
		return
	if current == null:
		_face_player()
		_rest_frames -= 1
		if _rest_frames <= 0:
			_next_pattern()
		return
	pattern_frame += 1
	if _update_pattern(current.id, pattern_frame):
		current = null
		_rest_frames = scaled(boss_data().rest_frames)


func _next_pattern() -> void:
	current = sequencer.pick(boss_data().patterns, phase, severed, _player_distance())
	if current == null:
		_rest_frames = 10
		return
	pattern_frame = 0
	_start_pattern(current.id)


func _face_player() -> void:
	var player: Player = target()
	if player != null and absf(player.global_position.x - global_position.x) > 8.0:
		facing = 1 if player.global_position.x > global_position.x else -1


func _player_distance() -> float:
	var player: Player = target()
	return absf(player.global_position.x - global_position.x) if player != null else INF


## Starts pattern [param id] (its first frame follows in _update_pattern).
func _start_pattern(_id: StringName) -> void:
	pass


## Advances pattern [param id] by one frame; [param frame] counts from 1. Returns true
## when it has finished.
func _update_pattern(_id: StringName, _frame: int) -> bool:
	return true


## Stops pattern [param id] at once (a flinch or a severed part): hide its hitboxes and
## reset its pose.
func _cancel_pattern(_id: StringName) -> void:
	pass


## A new phase began.
func _on_phase_changed(_phase: int) -> void:
	pass


## [param part] was torn off.
func _on_part_severed(_part: BossPart) -> void:
	pass


func _on_died() -> void:
	if current != null:
		_cancel_pattern(current.id)
		current = null
	started = false
	_dying_frames = DEATH_SEQUENCE_FRAMES
	contact_hitbox.active = false
	hurtbox.set_deferred(&"monitorable", false)
	for part: BossPart in parts.values():
		part.hurtbox().set_deferred(&"monitorable", false)
	collision_layer = 0
	velocity = Vector2.ZERO
	Game.stats.add_xp(data.xp)
	Events.enemy_killed.emit(data.id, global_position)
	GameCamera.shake(get_tree(), 3.0, 30)


## The death sequence: it shakes and bursts, drops its reward, then fades.
func _update_dying() -> void:
	_dying_frames -= 1
	set_flash(0.4 + 0.6 * float(_dying_frames % 8 < 4), Color("ef6a6a"))
	if _dying_frames % BURST_EVERY == 0:
		var at: Vector2 = global_position + body_rect.position + Vector2(randf() * body_rect.size.x, randf() * body_rect.size.y)
		HitSpark.spawn(get_tree(), at, Color("fbe69b"), true)
		GameCamera.shake(get_tree(), 2.0, 6)
	if _dying_frames == 30:
		_drop_reward()
		GameCamera.shake(get_tree(), 6.0, 24)
		Events.boss_defeated.emit(data.id)
		defeated.emit()
	if _dying_frames < 30:
		modulate.a = _dying_frames / 30.0
	if _dying_frames <= 0:
		queue_free()


func _drop_reward() -> void:
	var reward: ItemData = Game.item(boss_data().reward)
	if reward == null:
		return
	var at: Vector2 = global_position + Vector2(0, -40)
	if reward is RelicData:
		var relic: RelicData = reward as RelicData
		if Game.owns_relic(relic):
			return
		var pickup: RelicPickup = (load("res://scenes/world/pickups/relic_pickup.tscn") as PackedScene).instantiate() as RelicPickup
		pickup.ability = relic.ability
		pickup.title = relic.display_name
		pickup.detail = relic.description
		pickup.position = get_parent().to_local(global_position) if get_parent() is Node2D else global_position
		get_parent().add_child.call_deferred(pickup)
		return
	var drop: LootTable.Drop = LootTable.Drop.new()
	drop.kind = &"item"
	drop.item_id = reward.id
	drop.amount = 1
	Pickup.spawn(get_parent(), at, drop)
