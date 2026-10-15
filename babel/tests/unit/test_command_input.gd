extends GutTest
## SPL-001 command recognizer: notation, timing windows, facing, leniency.

const RIGHT: int = 1
const LEFT: int = -1
const DOWN: Vector2i = Vector2i(0, 1)
const DOWN_RIGHT: Vector2i = Vector2i(1, 1)
const RIGHT_DIR: Vector2i = Vector2i(1, 0)
const LEFT_DIR: Vector2i = Vector2i(-1, 0)
const NEUTRAL: Vector2i = Vector2i.ZERO

var input: CommandInput


func before_each() -> void:
	input = CommandInput.new()


func _feed(steps: Array) -> void:
	# steps: [[direction, frame], ...]
	for step: Array in steps:
		input.record(step[0], step[1])


func test_quarter_circle_forward_matches() -> void:
	_feed([[DOWN, 0], [DOWN_RIGHT, 4], [RIGHT_DIR, 8]])
	assert_true(input.matches("D,DF,F", 10, RIGHT, 24))


func test_mirrored_when_facing_left() -> void:
	_feed([[DOWN, 0], [Vector2i(-1, 1), 4], [LEFT_DIR, 8]])
	assert_true(input.matches("D,DF,F", 10, LEFT, 24), "down, down-left, left is D,DF,F facing left")
	assert_false(input.matches("D,DF,F", 10, RIGHT, 24))


func test_too_slow_fails() -> void:
	_feed([[DOWN, 0], [DOWN_RIGHT, 20], [RIGHT_DIR, 40]])
	assert_false(input.matches("D,DF,F", 42, RIGHT, 24))


func test_wrong_order_fails() -> void:
	_feed([[RIGHT_DIR, 0], [DOWN_RIGHT, 4], [DOWN, 8]])
	assert_false(input.matches("D,DF,F", 10, RIGHT, 24))


func test_noise_between_steps_is_allowed() -> void:
	_feed([[DOWN, 0], [NEUTRAL, 2], [DOWN, 3], [DOWN_RIGHT, 6], [RIGHT_DIR, 9]])
	assert_true(input.matches("D,DF,F", 11, RIGHT, 24))


func test_last_direction_may_be_released_just_before_the_press() -> void:
	_feed([[DOWN, 0], [DOWN_RIGHT, 4], [RIGHT_DIR, 8], [NEUTRAL, 12]])
	assert_true(input.matches("D,DF,F", 16, RIGHT, 24), "released 4 frames ago: still counts")
	assert_false(input.matches("D,DF,F", 30, RIGHT, 40), "released 18 frames ago: too late")


func test_back_forward_after_turning() -> void:
	# Facing right, press left (Elam turns), then right: read with the final facing it is B,F.
	_feed([[LEFT_DIR, 0], [NEUTRAL, 4], [RIGHT_DIR, 6]])
	assert_true(input.matches("B,F", 8, RIGHT, 20))


func test_double_tap_needs_two_separate_presses() -> void:
	_feed([[DOWN, 0]])
	assert_false(input.matches("D,D", 10, RIGHT, 20), "one held press is not two")
	_feed([[NEUTRAL, 12], [DOWN, 14]])
	assert_true(input.matches("D,D", 16, RIGHT, 20))


func test_plain_attack_matches_nothing() -> void:
	assert_false(input.matches("D,DF,F", 5, RIGHT, 24))
	_feed([[NEUTRAL, 0]])
	assert_false(input.matches("B,F", 5, RIGHT, 24))
