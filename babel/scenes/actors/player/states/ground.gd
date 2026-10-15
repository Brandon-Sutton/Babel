extends State
## Standing, walking and running (PLR-003, PLR-025). Instant start and stop, like
## Symphony of the Night. A double-tap starts a run (Player.running).

@onready var player: Player = owner as Player


func enter(_previous: StringName) -> void:
	player.set_crouching(false)


func exit() -> void:
	player.animation_player.speed_scale = 1.0


func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		machine.transition_to(&"Air")
		return
	var x: float = player.input_x()
	player.face(x)
	player.velocity.x = x * player.move_speed()
	player.apply_gravity(delta)
	if player.try_relic_arm():
		return
	if Input.is_action_just_pressed(&"attack_right"):
		if not player.try_special():
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
	_play_gait(x)


## Idle, walk or run. Without run art the walk plays faster (run_anim_scale).
func _play_gait(x: float) -> void:
	if x == 0.0:
		player.animation_player.speed_scale = 1.0
		player.play_animation(&"idle")
		return
	var has_run_art: bool = player.animation_player.has_animation(player.resolve_animation(&"run"))
	if player.running and has_run_art:
		player.animation_player.speed_scale = 1.0
		player.play_animation(&"run")
		return
	player.animation_player.speed_scale = player.tuning.run_anim_scale if player.running else 1.0
	player.play_animation(&"walk")
