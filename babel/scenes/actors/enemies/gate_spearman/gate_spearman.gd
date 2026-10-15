extends Enemy
## Gate Spearman (ENM-007): shade of a Babylonian gate guard with five telegraphed
## attacks, each with its own answer:
##   STAB      close, chest height (a crouch is still hit) -> jump it or back-dash out
##   SWEEP     close, along the floor          -> jump over it
##   ANTI_AIR  you jump in close or over it    -> don't jump at it (short wind-up)
##   FIREBALL  you keep your distance          -> crouch under it, jump it, or cut it
##   LEAP      mid range: leaps over and plunges straight down -> step out from under
## Every wind-up flashes gold; a staggering hit during a wind-up cancels the attack.
## Sprite: PixelLab character 34128d92 (ART-003), one animation group per attack.

enum Attack { NONE = -1, STAB, SWEEP, ANTI_AIR, FIREBALL, LEAP }
enum Phase { ADVANCE, WINDUP, ACTIVE, AIRBORNE, RECOVER }

const CLOSE_RANGE: float = 76.0
const ANTI_AIR_RANGE: float = 110.0
## How far above its feet a jumping player can be and still draw the anti-air.
const ANTI_AIR_HEIGHT: float = 180.0
const FIREBALL_MIN_RANGE: float = 150.0
const LEAP_MIN_RANGE: float = 100.0
const LEAP_MAX_RANGE: float = 220.0
const FIREBALL_COOLDOWN: int = 160
const LEAP_COOLDOWN: int = 200
const BETWEEN_ATTACKS: int = 20
const LEAP_LAUNCH_SPEED: float = 640.0
const LEAP_MAX_DRIFT: float = 560.0
const PLUNGE_SPEED: float = 620.0
const TELEGRAPH: Color = Color("fbe69b")
## Anti-air: the painted spear tip (anti_air frame 3) and the top of the spear-light.
const SPEAR_TIP: Vector2 = Vector2(58, -87)
const SPEAR_LIGHT_END: Vector2 = Vector2(64, -164)
const ARMOR: Color = Color("2e2939")
const ARMOR_LIGHT: Color = Color("4b3d6e")
const GOLD: Color = Color("c59c5c")
const SHAFT: Color = Color("82633f")


## Timing, reach and animations of one attack.
class Spec:
	var windup: int
	var active: int
	var recover: int
	## Hitbox centre (position) and size when facing right, relative to the feet. For
	## the fireball, the centre is where the fireball spawns.
	var box: Rect2
	var power_bonus: int
	var lunge: float
	## Animations for the windup, active and recover phases.
	var anims: Array[StringName]

	func _init(p_windup: int, p_active: int, p_recover: int, p_box: Rect2, p_power: int,
			p_lunge: float, p_anims: Array[StringName]) -> void:
		windup = p_windup
		active = p_active
		recover = p_recover
		box = p_box
		power_bonus = p_power
		lunge = p_lunge
		anims = p_anims


## Set by tests (or scripted moments) to pick the next attack regardless of range.
var forced_attack: Attack = Attack.NONE
var attack: Attack = Attack.NONE
var phase: Phase = Phase.ADVANCE

var _specs: Dictionary[Attack, Spec] = {}
var _timer: int = 0
var _air_frames: int = 0
var _cooldown: int = 0
var _fireball_cooldown: int = 0
var _leap_cooldown: int = 0
var _sweep_next: bool = false

@onready var _spear: Hitbox = %SpearHitbox
@onready var _spear_shape: CollisionShape2D = %SpearShape


func _ready() -> void:
	super._ready()
	# Each spearman resizes its own copy of the spear shape per attack.
	_spear_shape.shape = _spear_shape.shape.duplicate() as Shape2D
	_spear.owner_node = self
	_spear.knockback = 180.0
	_spear.hit_stop_frames = 3
	# Boxes follow the art: the stab is at chest height (the painted spear crosses a
	# crouching head, so a crouch does not dodge it), the sweep
	# scrapes the floor front to back (jump it), the anti-air spear points up and
	# forward (the box reaches past the painted tip, along the spear-light streak drawn
	# in _draw), the fireball leaves the hand where the cast frame paints it, and the
	# plunge spear points down below the body.
	_specs = {
		Attack.STAB: Spec.new(28, 8, 36, Rect2(44, -50, 56, 8), 4, 90.0,
				[&"windup", &"thrust", &"recover"]),
		Attack.SWEEP: Spec.new(24, 10, 36, Rect2(10, -8, 110, 14), 3, 0.0,
				[&"sweep_windup", &"sweep", &"sweep_recover"]),
		Attack.ANTI_AIR: Spec.new(12, 10, 32, Rect2(40, -112, 40, 104), 5, 100.0,
				[&"anti_air_windup", &"anti_air", &"anti_air_recover"]),
		Attack.FIREBALL: Spec.new(26, 6, 40, Rect2(58, -61, 0, 0), 2, 0.0,
				[&"cast_windup", &"cast", &"cast_recover"]),
		Attack.LEAP: Spec.new(16, 0, 40, Rect2(8, -14, 48, 28), 6, 0.0,
				[&"leap_windup", &"leap_plunge", &"leap_land"]),
	}


func _behave(_delta: float) -> void:
	_tick_cooldowns()
	queue_redraw()
	match phase:
		Phase.ADVANCE:
			_advance()
		Phase.WINDUP:
			velocity.x = 0.0
			set_flash(0.25 + 0.35 * float(_timer % 8 < 4), TELEGRAPH)
			_timer -= 1
			if _timer <= 0:
				set_flash(0.0)
				_begin_active()
		Phase.ACTIVE:
			velocity.x = move_toward(velocity.x, 0.0, 12.0)
			_timer -= 1
			if _timer <= 0:
				_end_active()
		Phase.AIRBORNE:
			_airborne()
		Phase.RECOVER:
			velocity.x = 0.0
			_timer -= 1
			if _timer <= 0:
				attack = Attack.NONE
				phase = Phase.ADVANCE
				_cooldown = BETWEEN_ATTACKS


func _advance() -> void:
	var player: Player = target()
	if player == null or Game.stats.is_dead():
		velocity.x = 0.0
		play_animation(&"idle")
		return
	var offset: Vector2 = player.global_position - global_position
	var in_range: bool = target_in_range()
	var jumping_in: bool = _is_jumping_in(player, offset)
	if not in_range and not jumping_in:
		velocity.x = 0.0
		play_animation(&"idle")
		return
	facing = 1 if offset.x > 0.0 else -1
	var choice: Attack = _choose_attack(absf(offset.x), jumping_in)
	if choice != Attack.NONE:
		_start_attack(choice)
		return
	if absf(offset.x) > CLOSE_RANGE:
		velocity.x = facing * data.move_speed
		play_animation(&"walk")
	else:
		velocity.x = 0.0
		play_animation(&"idle")


## True if the player is in the air above and close enough to be met with the anti-air.
func _is_jumping_in(player: Player, offset: Vector2) -> bool:
	return not player.is_on_floor() and absf(offset.x) < ANTI_AIR_RANGE \
			and offset.y < -24.0 and offset.y > -ANTI_AIR_HEIGHT


## Picks the next attack, or NONE to keep walking.
func _choose_attack(distance: float, jumping_in: bool) -> Attack:
	if _cooldown > 0 or not is_on_floor():
		return Attack.NONE
	if forced_attack != Attack.NONE:
		var forced: Attack = forced_attack
		forced_attack = Attack.NONE
		return forced
	if jumping_in:
		return Attack.ANTI_AIR
	if distance <= CLOSE_RANGE:
		_sweep_next = not _sweep_next
		return Attack.SWEEP if _sweep_next else Attack.STAB
	var options: Array[Attack] = []
	if distance >= FIREBALL_MIN_RANGE and _fireball_cooldown == 0:
		options.append(Attack.FIREBALL)
	if distance >= LEAP_MIN_RANGE and distance <= LEAP_MAX_RANGE and _leap_cooldown == 0:
		options.append(Attack.LEAP)
	if options.is_empty():
		return Attack.NONE
	var picked: Attack = options.pick_random()
	return picked


func _start_attack(choice: Attack) -> void:
	attack = choice
	velocity.x = 0.0
	_set_phase(Phase.WINDUP, _spec().windup)


func _begin_active() -> void:
	var spec: Spec = _spec()
	var player: Player = target()
	match attack:
		Attack.FIREBALL:
			# The cast frame holds the painted fireball; the real one replaces it after.
			_set_phase(Phase.ACTIVE, spec.active)
		Attack.LEAP:
			# Rise so the apex is above where the player stands, then plunge from there.
			var dx: float = player.global_position.x - global_position.x if player != null else facing * 140.0
			var rise_time: float = LEAP_LAUNCH_SPEED / gravity
			velocity = Vector2(clampf(dx / rise_time, -LEAP_MAX_DRIFT, LEAP_MAX_DRIFT), -LEAP_LAUNCH_SPEED)
			_leap_cooldown = LEAP_COOLDOWN
			_air_frames = 0
			# The plunge is the attack; body contact would land first and steal the hit.
			contact_hitbox.active = false
			phase = Phase.AIRBORNE
			play_animation(&"leap_rise", true)
		_:
			if attack == Attack.ANTI_AIR and player != null:
				# The player may have jumped over during the wind-up.
				facing = 1 if player.global_position.x > global_position.x else -1
			_arm_spear(spec)
			velocity.x = facing * spec.lunge
			_set_phase(Phase.ACTIVE, spec.active)


func _end_active() -> void:
	var spec: Spec = _spec()
	_spear.active = false
	if attack == Attack.FIREBALL:
		Fireball.launch(get_parent(), global_position + Vector2(spec.box.position.x * facing, spec.box.position.y),
				facing, data.attack + spec.power_bonus)
		_fireball_cooldown = FIREBALL_COOLDOWN
	_set_phase(Phase.RECOVER, spec.recover)


## Leap: rise, plunge spear-first from the apex, and end the attack on landing.
func _airborne() -> void:
	_air_frames += 1
	if velocity.y >= 0.0 and not _spear.active and _air_frames > 1:
		velocity = Vector2(0.0, PLUNGE_SPEED)
		_arm_spear(_spec())
		play_animation(&"leap_plunge", true)
	if _air_frames > 2 and is_on_floor():
		_spear.active = false
		contact_hitbox.active = data.contact_damage
		velocity.x = 0.0
		GameCamera.shake(get_tree(), 2.0, 8)
		HitSpark.spawn(get_tree(), global_position + Vector2(0, -4), TELEGRAPH, true)
		_set_phase(Phase.RECOVER, _spec().recover)


func _arm_spear(spec: Spec) -> void:
	var rect: RectangleShape2D = _spear_shape.shape as RectangleShape2D
	rect.size = spec.box.size
	_spear_shape.position = Vector2(spec.box.position.x * facing, spec.box.position.y)
	_spear.attack = data.attack + spec.power_bonus
	_spear.active = true


func _set_phase(next: Phase, frames: int) -> void:
	phase = next
	_timer = frames
	match next:
		Phase.WINDUP:
			play_animation(_spec().anims[0], true)
		Phase.ACTIVE:
			play_animation(_spec().anims[1], true)
		Phase.RECOVER:
			play_animation(_spec().anims[2], true)


func _spec() -> Spec:
	return _specs[attack]


func _tick_cooldowns() -> void:
	_cooldown = maxi(0, _cooldown - 1)
	_fireball_cooldown = maxi(0, _fireball_cooldown - 1)
	_leap_cooldown = maxi(0, _leap_cooldown - 1)


func _on_damaged(_info: DamageInfo, staggered: bool) -> void:
	if staggered and phase == Phase.WINDUP:
		set_flash(1.0)
		_set_phase(Phase.RECOVER, _spec().recover)


func _on_died() -> void:
	_spear.active = false
	super._on_died()


func _draw() -> void:
	if attack == Attack.ANTI_AIR and phase == Phase.ACTIVE:
		# Spear-light: a streak from the painted spear tip up through the hitbox's reach.
		var fade: float = float(_timer) / _spec().active
		var tip: Vector2 = Vector2(SPEAR_TIP.x * facing, SPEAR_TIP.y)
		var reach: Vector2 = Vector2(SPEAR_LIGHT_END.x * facing, SPEAR_LIGHT_END.y)
		draw_line(tip, reach, Color(TELEGRAPH, 0.8 * fade), 3.0)
		draw_line(tip, reach, Color(Color.WHITE, fade), 1.0)
	if sprite != null:
		return
	draw_rect(Rect2(-9, -66, 18, 50), ARMOR)
	draw_rect(Rect2(-9, -66, 18, 3), ARMOR_LIGHT)
	draw_rect(Rect2(-7, -16, 6, 16), ARMOR)
	draw_rect(Rect2(1, -16, 6, 16), ARMOR)
	draw_rect(Rect2(-8, -80, 16, 14), ARMOR_LIGHT)
	draw_rect(Rect2(-8, -84, 16, 4), GOLD)
	var y: float = -48.0
	draw_line(Vector2(-facing * 18.0, y), Vector2(facing * 30.0, y), SHAFT, 2.0)
