extends Area2D
## Archivist Nabu (NPC-004, NPC-005), the ghost scribe who keeps the tower's shop and
## sells the Surveyor's Maps (MAP-005). Stand near him and press Up to open his shop
## (ShopMenu). Drawn in code until his sprite exists (ART-019): a hooded, translucent
## scribe hovering beside a lectern of clay tablets, facing the way he greets visitors.

const PROMPT: String = "UP  TALK"
const GOLD: Color = Color("d4b06e")
const ROBE: Color = Color(0.66, 0.74, 0.88, 0.82)
const ROBE_SHADE: Color = Color(0.42, 0.49, 0.66, 0.82)
const ROBE_LIGHT: Color = Color(0.88, 0.92, 0.98, 0.9)
const HOLLOW: Color = Color("16131f")
const EYES: Color = Color("fbe69b")
const STONE: Color = Color("5a4e60")
const STONE_LIGHT: Color = Color("7a6e80")
const CLAY: Color = Color("b07a4a")
const CLAY_LIGHT: Color = Color("d8a878")
const CLAY_DARK: Color = Color("6e4628")

## What he sells.
@export var shop: ShopData = preload("res://data/shops/nabu.tres")
## 1 faces right, -1 faces left (toward a visitor coming from the left).
@export var facing: int = -1

var _player_near: Player
var _cooldown: int = 0
var _time: float = 0.0


func _ready() -> void:
	body_entered.connect(func(body: Node2D) -> void:
		if body is Player:
			_player_near = body as Player)
	body_exited.connect(func(body: Node2D) -> void:
		if body == _player_near:
			_player_near = null)


func _physics_process(delta: float) -> void:
	_time += delta
	if _cooldown > 0:
		_cooldown -= 1
	if _player_near != null and _cooldown == 0 and _player_near.is_on_floor() \
			and Input.is_action_just_pressed(&"move_up") and not get_tree().paused:
		talk()
	queue_redraw()


## Opens his shop, if the game has a shop screen.
func talk() -> void:
	var menu: Node = get_tree().get_first_node_in_group(&"shop_menu")
	if menu == null:
		return
	_cooldown = 20
	menu.call(&"open", shop)


func _draw() -> void:
	_draw_lectern()
	_draw_scribe()
	if _player_near != null and _cooldown == 0:
		var prompt: String = tr(PROMPT)
		var width: int = PixelFont.text_width(prompt)
		PixelFont.draw_text(self, Vector2(-floori(width / 2.0), -98), prompt, GOLD, 1, Color("0b0a10"))


## A stone lectern behind him with a tablet on it, and a stack of tablets at its foot.
func _draw_lectern() -> void:
	var side: float = -facing
	var x: float = 16.0 if side > 0.0 else -26.0
	draw_rect(Rect2(x + 3, -36, 5, 36), STONE)
	draw_rect(Rect2(x + 3, -36, 1, 36), STONE_LIGHT)
	draw_rect(Rect2(x - 1, -40, 13, 4), STONE_LIGHT)
	draw_rect(Rect2(x - 1, -37, 13, 1), STONE)
	draw_rect(Rect2(x, -2, 11, 2), STONE)
	_draw_tablet(Vector2(x + 1, -48))
	for i: int in 3:
		_draw_tablet(Vector2(x + 13 * side - (2 if side < 0.0 else 0) + i % 2, -7 - i * 6))


func _draw_tablet(at: Vector2) -> void:
	draw_rect(Rect2(at, Vector2(9, 7)), CLAY)
	draw_rect(Rect2(at, Vector2(9, 1)), CLAY_LIGHT)
	draw_rect(Rect2(at + Vector2(0, 6), Vector2(9, 1)), CLAY_DARK)
	for row: int in 2:
		draw_rect(Rect2(at + Vector2(2, 2 + row * 2), Vector2(5, 1)), CLAY_DARK)


## A hooded robe that thins into wisps instead of feet, bobbing gently.
func _draw_scribe() -> void:
	var bob: float = roundf(sin(_time * 2.2) * 2.0)
	var glow: float = 0.5 + 0.5 * sin(_time * 3.0)
	# Robe: widening from the shoulders down, shaded on the side away from the light.
	for y: int in range(-62, -10):
		var t: float = float(y + 62) / 52.0
		var half: int = roundi(lerpf(8.0, 12.0, t))
		var top: float = y + bob
		draw_rect(Rect2(-half, top, half * 2, 1), ROBE)
		draw_rect(Rect2(half - 3 if facing < 0 else -half, top, 3, 1), ROBE_SHADE)
		draw_rect(Rect2(-half if facing < 0 else half - 1, top, 1, 1), ROBE_LIGHT)
	# Wisps where the feet would be, fading out.
	for column: int in range(-11, 12, 3):
		var length: int = 4 + (column * 7 + 20) % 6
		for i: int in length:
			draw_rect(Rect2(column, -10 + i + bob, 2, 1), Color(ROBE, ROBE.a * (1.0 - float(i) / length)))
	# Hood and the dark of the face, with two glowing eyes.
	draw_rect(Rect2(-8, -76 + bob, 16, 15), ROBE_SHADE)
	draw_rect(Rect2(-7, -77 + bob, 14, 2), ROBE_LIGHT)
	var face_x: float = -6.0 if facing < 0 else -2.0
	draw_rect(Rect2(face_x, -72 + bob, 8, 9), HOLLOW)
	var eye_x: float = face_x + (1.0 if facing < 0 else 4.0)
	draw_rect(Rect2(eye_x, -69 + bob, 1, 1), Color(EYES, 0.7 + 0.3 * glow))
	draw_rect(Rect2(eye_x + 3, -69 + bob, 1, 1), Color(EYES, 0.7 + 0.3 * glow))
	# A sleeve held out toward the visitor, a stylus in the hand.
	var reach: float = 9.0 * facing
	draw_rect(Rect2(minf(0.0, reach) - 2, -50 + bob, absf(reach) + 4, 5), ROBE)
	var hand_x: float = reach + (-3.0 if facing < 0 else 1.0)
	draw_rect(Rect2(hand_x, -49 + bob, 2, 3), ROBE_LIGHT)
	draw_rect(Rect2(hand_x + (-2.0 if facing < 0 else 2.0), -55 + bob, 1, 7), CLAY_DARK)
