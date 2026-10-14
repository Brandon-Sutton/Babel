extends Enemy
## Mudborn (ENM-002): a dead builder sealed in clay. Patrols, turning at walls and
## ledges; shambles toward the player when near and never walks off a ledge while
## chasing. Hurts on contact. Placeholder drawing until ART-003.

const CLAY: Color = Color("7c3524")
const CLAY_DARK: Color = Color("4a1f17")
const CLAY_LIGHT: Color = Color("b45a37")
const EYE: Color = Color("e0b34a")

var _turn_cooldown: int = 0

@onready var _ledge_ray: RayCast2D = %LedgeRay


func _behave(_delta: float) -> void:
	var player: Player = target()
	var chasing: bool = target_in_range()
	if chasing:
		facing = 1 if player.global_position.x > global_position.x else -1
	_ledge_ray.position.x = facing * 16.0
	_ledge_ray.force_raycast_update()
	var ledge_ahead: bool = is_on_floor() and not _ledge_ray.is_colliding()
	if not chasing and _turn_cooldown == 0 and (is_on_wall() or ledge_ahead):
		facing = -facing
		_turn_cooldown = 20
	if _turn_cooldown > 0:
		_turn_cooldown -= 1
	velocity.x = 0.0 if chasing and ledge_ahead else facing * data.move_speed


func _draw() -> void:
	var bob: float = 1.0 if floori(Time.get_ticks_msec() / 250.0) % 2 == 0 else 0.0
	draw_rect(Rect2(-13, -54 + bob, 26, 54 - bob), CLAY)
	draw_rect(Rect2(-13, -54 + bob, 26, 3), CLAY_LIGHT)
	draw_rect(Rect2(-15, -64 + bob, 22, 14), CLAY_DARK)
	draw_rect(Rect2(-11 + facing * 2, -62 + bob, 14, 10), CLAY)
	draw_rect(Rect2(-2 + facing * 5, -59 + bob, 2, 2), EYE)
	draw_rect(Rect2(facing * 15 - 3, -44 + bob, 6, 30), CLAY_DARK)
	draw_rect(Rect2(-13, -6, 10, 6), CLAY_DARK)
	draw_rect(Rect2(3, -6, 10, 6), CLAY_DARK)
