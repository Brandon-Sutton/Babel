extends State
## Knocked back after a hit (PLR-009). No control for hurt_frames; the longer
## invulnerability window (with flicker) is handled by the player script.

var _frame: int = 0

@onready var player: Player = owner as Player


func enter(_previous: StringName) -> void:
	_frame = 0
	player.set_crouching(false)
	player.stop_attack()
	var knockback: Vector2 = player.tuning.knockback
	player.velocity = Vector2(player.knockback_direction * knockback.x, knockback.y)
	player.play_animation(&"hurt")


func physics_update(delta: float) -> void:
	_frame += 1
	player.apply_gravity(delta)
	if player.is_on_floor() and _frame > 2:
		player.velocity.x = move_toward(player.velocity.x, 0.0, 30.0)
	if _frame >= player.tuning.hurt_frames:
		machine.transition_to(&"Ground" if player.is_on_floor() else &"Air")
