extends GutTest
## PLR-004: derived jump physics land on the tuned heights in the 60 Hz simulation.

var tuning: PlayerTuning = preload("res://data/player/player_tuning.tres")


## Simulates the player's jump: the take-off frame moves at full speed, then gravity
## applies before each move (as in the Air state). Returns the apex height.
func _simulated_apex(launch: float) -> float:
	var dt: float = 1.0 / Engine.physics_ticks_per_second
	var velocity: float = -launch
	var y: float = 0.0
	var apex: float = 0.0
	y += velocity * dt
	while velocity < 0.0:
		velocity += tuning.gravity() * dt
		y += velocity * dt
		apex = minf(apex, y)
	return -apex


func test_jump_reaches_jump_height() -> void:
	assert_almost_eq(_simulated_apex(tuning.jump_velocity()), tuning.jump_height, 1.5)


func test_double_jump_reaches_its_height() -> void:
	assert_almost_eq(_simulated_apex(tuning.double_jump_velocity()), tuning.double_jump_height, 1.5)


func test_backdash_speed_covers_distance() -> void:
	assert_almost_eq(tuning.backdash_speed() * tuning.backdash_frames / 60.0, tuning.backdash_distance, 0.01)
