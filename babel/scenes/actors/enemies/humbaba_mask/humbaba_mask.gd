extends Enemy
## Humbaba Mask (ENM-006): a floating guardian mask that crosses the screen in a sine
## wave, Medusa-head style. Ignores walls; frees itself once far from the player.
## Spawned by MaskSpawner. Placeholder drawing until ART-003.

const AMPLITUDE: float = 30.0
const FREQUENCY: float = 2.6
const DESPAWN_DISTANCE: float = 480.0
const FACE: Color = Color("c59c5c")
const FACE_DARK: Color = Color("82633f")
const HOLLOW: Color = Color("16131f")

var _time: float = 0.0


func _ready() -> void:
	super._ready()
	uses_gravity = false
	collision_mask = 0


func _behave(delta: float) -> void:
	_time += delta
	velocity.x = facing * data.move_speed
	velocity.y = cos(_time * FREQUENCY) * AMPLITUDE * FREQUENCY
	var player: Player = target()
	if player != null and absf(player.global_position.x - global_position.x) > DESPAWN_DISTANCE:
		queue_free()


func _draw() -> void:
	draw_rect(Rect2(-10, -22, 20, 22), FACE)
	draw_rect(Rect2(-12, -18, 2, 14), FACE_DARK)
	draw_rect(Rect2(10, -18, 2, 14), FACE_DARK)
	draw_rect(Rect2(-10, -22, 20, 2), Color("d4b06e"))
	draw_rect(Rect2(-6, -16, 4, 4), HOLLOW)
	draw_rect(Rect2(2, -16, 4, 4), HOLLOW)
	draw_rect(Rect2(-6, -7, 12, 2), HOLLOW)
	draw_rect(Rect2(-4, -5, 2, 2), HOLLOW)
	draw_rect(Rect2(2, -5, 2, 2), HOLLOW)
