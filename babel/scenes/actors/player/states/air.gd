extends State
## Jumping and falling (PLR-004): full air control, variable jump height (releasing jump
## cuts the rise), coyote time, jump buffering and the relic-gated double jump (PLR-013).

@onready var player: Player = owner as Player


func physics_update(delta: float) -> void:
	var x: float = player.input_x()
	player.face(x)
	# A jump out of a run keeps run speed (PLR-025).
	player.velocity.x = x * player.move_speed()
	if Input.is_action_just_released(&"jump") and player.velocity.y < 0.0:
		player.velocity.y *= player.tuning.jump_cut_factor
	player.apply_gravity(delta)
	if player.jump_buffer > 0:
		if player.coyote > 0:
			player.consume_jump()
			player.jump()
		elif player.air_jumps_left > 0 and Input.is_action_just_pressed(&"jump"):
			player.consume_jump()
			player.double_jump()
	if player.try_relic_arm():
		return
	if Input.is_action_just_pressed(&"attack_right"):
		if not player.try_special():
			machine.transition_to(&"Attack")
		return
	if player.is_on_floor() and player.velocity.y >= 0.0:
		machine.transition_to(&"Crouch" if Input.is_action_pressed(&"move_down") else &"Ground")
		return
	player.play_animation(&"jump" if player.velocity.y < 0.0 else &"fall")
