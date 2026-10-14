extends State
## Death (PLR-010): a last knockback, a fade, then a respawn request. The game-over
## screen (UI-014) will sit between the fade and the respawn.

const FADE_START: int = 50
const RESPAWN_FRAME: int = 130

var _frame: int = 0

@onready var player: Player = owner as Player


func enter(_previous: StringName) -> void:
	_frame = 0
	player.set_crouching(false)
	player.stop_attack()
	player.invulnerable_frames = 0
	player.velocity = Vector2(player.knockback_direction * 80.0, -200.0)
	player.sprite.modulate = Color(1.0, 0.55, 0.55)
	player.play_animation(&"death" if player.animation_player.has_animation(&"death") else &"hurt")


func physics_update(delta: float) -> void:
	_frame += 1
	player.apply_gravity(delta)
	if player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, 0.0, 6.0)
	if _frame > FADE_START:
		player.sprite.modulate.a = maxf(0.0, 1.0 - float(_frame - FADE_START) / (RESPAWN_FRAME - FADE_START))
	if _frame == RESPAWN_FRAME:
		player.respawn_requested.emit()
