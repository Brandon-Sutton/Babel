extends State
## Weapon swing (PLR-007/008): on the ground (stands still), crouching (low hitbox) or
## in the air (keeps air control). Startup, active and recovery frames come from
## WeaponData. Facing stays locked for the whole swing.

enum Kind { GROUND, CROUCH, AIR }

const ANIMATIONS: Dictionary[Kind, StringName] = {
	Kind.GROUND: &"attack", Kind.CROUCH: &"crouch_attack", Kind.AIR: &"jump_attack",
}

var _kind: Kind = Kind.GROUND
var _frame: int = 0
var _weapon: WeaponData
## True when the sheet has no swing art for this kind of attack (draw the placeholder arc).
var _needs_arc: bool = false

@onready var player: Player = owner as Player


func enter(previous: StringName) -> void:
	_weapon = Game.stats.weapon
	_frame = 0
	if not player.is_on_floor():
		_kind = Kind.AIR
	elif previous == &"Crouch" or Input.is_action_pressed(&"move_down"):
		_kind = Kind.CROUCH
	else:
		_kind = Kind.GROUND
	player.set_crouching(_kind == Kind.CROUCH)
	if _kind != Kind.AIR:
		player.velocity.x = 0.0
	# The weapon's own swing when it has one (the scythe's reap), else the shared one.
	var animation: StringName = player.resolve_animation(ANIMATIONS[_kind])
	var own_art: bool = player.animation_player.has_animation(animation)
	if not own_art:
		# Air attacks reuse the standing swing (the weapon's own, if it has one).
		animation = player.resolve_animation(&"attack")
	# The procedural arc stands in where the art has no smear of its own (the scythe's
	# reap), or where a crouching swing has to borrow the standing art.
	_needs_arc = (not own_art and _kind == Kind.CROUCH) or not player.animation_player.has_animation(animation) \
			or not player.equipment_rig.has_smear(animation)
	player.play_animation(animation, true)
	# Stretch the swing art to this weapon's timing (the mace is slower than the sword).
	var swing_seconds: float = _weapon.total_frames() / 60.0
	var art_seconds: float = player.animation_player.current_animation_length
	player.animation_player.speed_scale = art_seconds / swing_seconds if swing_seconds > 0.0 else 1.0


func exit() -> void:
	player.stop_attack()
	player.animation_player.speed_scale = 1.0


func physics_update(delta: float) -> void:
	_frame += 1
	if _frame == _weapon.startup_frames + 1:
		player.start_attack(_weapon, _kind == Kind.CROUCH, _needs_arc)
	elif _frame == _weapon.startup_frames + _weapon.active_frames + 1:
		player.stop_attack()

	if _kind == Kind.AIR:
		player.velocity.x = player.input_x() * player.tuning.walk_speed
		if Input.is_action_just_released(&"jump") and player.velocity.y < 0.0:
			player.velocity.y *= player.tuning.jump_cut_factor
		if player.is_on_floor() and player.velocity.y >= 0.0:
			_kind = Kind.GROUND
	else:
		player.velocity.x = 0.0
		if not player.is_on_floor():
			_kind = Kind.AIR
	player.apply_gravity(delta)

	if _frame >= _weapon.total_frames():
		if not player.is_on_floor():
			machine.transition_to(&"Air")
		elif Input.is_action_pressed(&"move_down"):
			machine.transition_to(&"Crouch")
		else:
			machine.transition_to(&"Ground")
