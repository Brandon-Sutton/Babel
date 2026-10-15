extends State
## Casting an Utterance or a weapon art (SPL-003, SPL-020). The Breath is already paid
## (Player.try_special). A wind-up of cast_frames, the effect for active_frames, then
## recovery_frames. Effects by SpellData.effect:
##   bolts      fire bolts fly ahead in a small spread (Išātu)
##   lunge      Elam dashes forward with the weapon out (Swift Thrust, Hooking Lunge)
##   shockwave  waves run along the floor both ways (Earthshaker)
##   cleave     one huge arc far ahead (Lion's Cleave)
##   whirl      a ring that hits all around, twice (Reaping Whirl)
## Until cast art exists, an Utterance tints Elam in its colour during the wind-up, and a
## weapon art plays the stance's attack.

var _move: SpellData
var _frame: int = 0

@onready var player: Player = owner as Player


func enter(_previous: StringName) -> void:
	_move = player.pending_move
	_frame = 0
	if player.is_on_floor():
		player.velocity.x = 0.0
	var is_art: bool = _move.effect != &"bolts"
	var animation: StringName = player.resolve_animation(&"attack" if is_art else &"cast")
	if not player.animation_player.has_animation(animation):
		animation = player.resolve_animation(&"idle")
	player.play_animation(animation, true)
	if is_art:
		var seconds: float = (_move.cast_frames + maxi(_move.active_frames, 1)) / 60.0
		player.animation_player.speed_scale = player.animation_player.current_animation_length / seconds
	else:
		player.sprite.self_modulate = _move.color.lightened(0.45)


func exit() -> void:
	player.stop_attack()
	player.afterimages.active = false
	player.sprite.self_modulate = Color.WHITE
	player.animation_player.speed_scale = 1.0


func physics_update(delta: float) -> void:
	_frame += 1
	var active_end: int = _move.cast_frames + _move.active_frames
	if _frame == _move.cast_frames:
		player.sprite.self_modulate = Color.WHITE
		_begin_effect()
	if _move.effect == &"lunge" and _frame > _move.cast_frames and _frame <= active_end:
		player.velocity.x = player.facing * _move.distance / maxf(_move.active_frames / 60.0, 0.01)
	elif player.is_on_floor():
		player.velocity.x = 0.0
	if _move.effect == &"whirl" and _frame == _move.cast_frames + _move.active_frames / 2:
		player.weapon_hitbox.active = true
	if _frame == active_end:
		player.stop_attack()
		player.afterimages.active = false
	player.apply_gravity(delta)
	if _frame >= active_end + _move.recovery_frames:
		machine.transition_to(&"Ground" if player.is_on_floor() else &"Air")


func _begin_effect() -> void:
	var weapon: WeaponData = Game.stats.weapon
	var art_attack: int = Game.stats.attack_power() + _move.power
	match _move.effect:
		&"bolts":
			var spell_attack: int = _move.power + Game.stats.total(&"intelligence")
			for i: int in _move.count:
				var shot: PlayerShot = PlayerShot.create(&"bolt")
				shot.velocity = Vector2(player.facing * _move.speed, (i - (_move.count - 1) / 2.0) * 45.0)
				shot.size = Vector2(10, 8)
				shot.color = _move.color
				shot.attack = spell_attack
				shot.knockback = _move.knockback
				shot.launch(player.get_parent(), player.global_position + Vector2(player.facing * 16.0, -60.0))
		&"lunge":
			var reach: float = (weapon.reach if weapon != null else 46.0) + 12.0
			player.start_hitbox(Vector2(reach, 36.0), Vector2(Player.BODY_RADIUS + reach / 2.0, -50.0),
					art_attack, _move.knockback, 5)
			player.afterimages.active = true
			player.slash_fx.play_arc(reach, _move.color, _move.active_frames, player.facing, false)
		&"shockwave":
			for direction: int in [-1, 1]:
				var wave: PlayerShot = PlayerShot.create(&"wave")
				wave.velocity = Vector2(direction * _move.speed, 0.0)
				wave.size = Vector2(16, 14)
				wave.color = _move.color
				wave.attack = art_attack
				wave.knockback = _move.knockback
				wave.pierce = true
				wave.lifetime_frames = 60
				wave.launch(player.get_parent(), player.global_position + Vector2(direction * 18.0, -8.0))
			GameCamera.shake(get_tree(), 3.0, 10)
		&"cleave":
			player.start_hitbox(Vector2(_move.distance, 72.0), Vector2(Player.BODY_RADIUS + _move.distance / 2.0, -46.0),
					art_attack, _move.knockback, 8)
			player.slash_fx.play_arc(_move.distance, _move.color, _move.active_frames, player.facing, false)
			GameCamera.shake(get_tree(), 2.0, 8)
		&"whirl":
			player.start_hitbox(Vector2(_move.distance * 2.0, 84.0), Vector2(0.0, -44.0), art_attack, _move.knockback, 4)
			player.slash_fx.play_ring(_move.distance, _move.color, _move.active_frames)
