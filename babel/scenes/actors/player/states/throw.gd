extends State
## Throwing the carried Relic Arm (SUB-001). The Embers are already paid
## (Player.try_relic_arm); the shot leaves the hand on SHOT_FRAME. Until the throw art
## exists, the stance's attack plays sped up.

const SHOT_FRAME: int = 4
const TOTAL_FRAMES: int = 14

var _frame: int = 0

@onready var player: Player = owner as Player


func enter(_previous: StringName) -> void:
	_frame = 0
	if player.is_on_floor():
		player.velocity.x = 0.0
	var animation: StringName = player.resolve_animation(&"throw")
	if not player.animation_player.has_animation(animation):
		animation = player.resolve_animation(&"attack")
	player.play_animation(animation, true)
	player.animation_player.speed_scale = player.animation_player.current_animation_length / (TOTAL_FRAMES / 60.0)


func exit() -> void:
	player.animation_player.speed_scale = 1.0


func physics_update(delta: float) -> void:
	_frame += 1
	if not player.is_on_floor():
		player.velocity.x = player.input_x() * player.move_speed()
	player.apply_gravity(delta)
	if _frame == SHOT_FRAME:
		_throw(Game.stats.relic_arm)
	if _frame >= TOTAL_FRAMES:
		machine.transition_to(&"Ground" if player.is_on_floor() else &"Air")


func _throw(arm: RelicArmData) -> void:
	if arm == null:
		return
	var shot: PlayerShot = PlayerShot.create(&"tablet" if arm.flight == &"arc" else &"stone")
	shot.velocity = Vector2(player.facing * arm.speed, -arm.lift)
	shot.fall_gravity = arm.gravity
	shot.pierce = arm.pierce
	shot.through_walls = arm.flight == &"arc"
	shot.size = arm.size
	shot.color = arm.color
	shot.attack = arm.damage
	shot.add_to_group(PlayerShot.group_for(arm))
	shot.launch(player.get_parent(), player.global_position + Vector2(player.facing * 14.0, -56.0))
