extends State
## Back-dash (PLR-005): a quick slide backwards while still facing forward. From
## backdash_cancel_frame on it can be cancelled into an attack or a jump.

var _frame: int = 0

@onready var player: Player = owner as Player


func enter(_previous: StringName) -> void:
	_frame = 0
	player.play_animation(&"backdash")


func exit() -> void:
	player.backdash_cooldown = player.tuning.backdash_cooldown_frames


func physics_update(delta: float) -> void:
	_frame += 1
	if _frame > player.tuning.backdash_frames:
		player.velocity.x = 0.0
		machine.transition_to(&"Ground" if player.is_on_floor() else &"Air")
		return
	player.velocity.x = -player.facing * player.tuning.backdash_speed()
	player.apply_gravity(delta)
	if _frame >= player.tuning.backdash_cancel_frame:
		if Input.is_action_just_pressed(&"attack_right"):
			machine.transition_to(&"Attack")
			return
		if player.can_ground_jump() and player.consume_jump():
			player.jump()
			machine.transition_to(&"Air")
