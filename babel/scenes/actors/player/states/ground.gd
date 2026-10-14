extends State
## Standing and walking (PLR-003). Instant start and stop, like Symphony of the Night.

@onready var player: Player = owner as Player


func enter(_previous: StringName) -> void:
	player.set_crouching(false)


func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		machine.transition_to(&"Air")
		return
	var x: float = player.input_x()
	player.face(x)
	player.velocity.x = x * player.tuning.walk_speed
	player.apply_gravity(delta)
	if Input.is_action_just_pressed(&"attack_right"):
		machine.transition_to(&"Attack")
		return
	if Input.is_action_just_pressed(&"backdash") and player.backdash_cooldown == 0:
		machine.transition_to(&"Backdash")
		return
	if player.consume_jump():
		if Input.is_action_pressed(&"move_down") and player.on_one_way_platform():
			player.drop_through()
		else:
			player.jump()
		machine.transition_to(&"Air")
		return
	if Input.is_action_pressed(&"move_down"):
		machine.transition_to(&"Crouch")
		return
	player.play_animation(&"walk" if x != 0.0 else &"idle")
