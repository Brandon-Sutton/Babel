class_name PlayerTuning
extends Resource
## Movement and hit-reaction feel for the player (GDD §6.1). Edit
## res://data/player/player_tuning.tres; the player reads it every frame, so changes
## made in the inspector while the game runs apply immediately. Timings are frames at 60 Hz.

@export_group("Ground")
@export var walk_speed: float = 180.0
## Running (PLR-025): double-tap a direction within run_tap_frames and hold it.
@export var run_speed: float = 290.0
@export var run_tap_frames: int = 14
## Walk animation speed-up used while there is no run art yet.
@export var run_anim_scale: float = 1.6

@export_group("Jump")
## Apex height of a full jump in pixels (about 9 tiles).
@export var jump_height: float = 144.0
## Seconds from take-off to apex; with jump_height this sets gravity and jump speed.
@export var time_to_apex: float = 0.42
## Upward speed is multiplied by this when jump is released early (variable jump height).
@export_range(0.0, 1.0) var jump_cut_factor: float = 0.4
@export var max_fall_speed: float = 800.0
## Frames after walking off a ledge during which a jump still counts.
@export var coyote_frames: int = 6
## Frames a jump press is remembered before landing.
@export var jump_buffer_frames: int = 6
## Apex height of the mid-air jump granted by the Gazelle Anklet.
@export var double_jump_height: float = 96.0

@export_group("Back-dash")
@export var backdash_distance: float = 100.0
@export var backdash_frames: int = 15
## From this frame on, a back-dash can be cancelled into an attack or a jump.
@export var backdash_cancel_frame: int = 9
@export var backdash_cooldown_frames: int = 8

@export_group("Hurt")
@export var hurt_frames: int = 18
@export var invulnerable_frames: int = 70
## Knockback when hit: x away from the source, y upward (negative).
@export var knockback: Vector2 = Vector2(160.0, -220.0)

@export_group("Crouch")
## Frames the one-way platform collision stays off after dropping through.
@export var drop_through_frames: int = 12


## Gravity in px/s² derived from jump height and time to apex.
func gravity() -> float:
	return 2.0 * jump_height / (time_to_apex * time_to_apex)


## Take-off speed in px/s (positive; apply as negative y) that reaches [member jump_height]
## exactly in the fixed-step simulation.
func jump_velocity() -> float:
	return launch_speed(jump_height)


## Take-off speed of the mid-air jump in px/s.
func double_jump_velocity() -> float:
	return launch_speed(double_jump_height)


## Launch speed whose apex is [param height] px at the project's physics tick rate. The
## take-off frame moves at full speed before gravity applies, which adds v·dt/2 to the
## continuous apex v²/2g, so solve v²/2g + v·dt/2 = height for v.
func launch_speed(height: float) -> float:
	var g: float = gravity()
	var dt: float = 1.0 / Engine.physics_ticks_per_second
	var half_step: float = g * dt / 2.0
	return -half_step + sqrt(half_step * half_step + 2.0 * g * height)


## Back-dash speed in px/s.
func backdash_speed() -> float:
	return backdash_distance / (backdash_frames / 60.0)
