extends State
## Crouching (PLR-006): shorter hurtbox, can turn, attack low, back-dash, or drop through
## a one-way platform with Down + Jump.

@onready var player: Player = owner as Player


func enter(_previous: StringName) -> void:
	player.set_crouching(true)
	player.velocity.x = 0.0


func exit() -> void:
	player.set_crouching(false)


func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		machine.transition_to(&"Air")
		return
	player.face(player.input_x())
	player.velocity.x = 0.0
	player.apply_gravity(delta)
	if Input.is_action_just_pressed(&"attack_right"):
		machine.transition_to(&"Attack")
		return
	if Input.is_action_just_pressed(&"backdash") and player.backdash_cooldown == 0:
		machine.transition_to(&"Backdash")
		return
	if player.consume_jump():
		if player.on_one_way_platform():
			player.drop_through()
		else:
			player.jump()
		machine.transition_to(&"Air")
		return
	if not Input.is_action_pressed(&"move_down"):
		machine.transition_to(&"Ground")
		return
	player.play_animation(&"crouch")
