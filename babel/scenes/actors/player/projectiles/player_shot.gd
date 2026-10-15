class_name PlayerShot
extends Area2D
## Projectiles thrown or cast by Elam (SUB-001..003, SPL-010, SPL-020): Relic Arms,
## Utterance fire bolts and weapon-art shockwaves. Hits enemies and breakables; bursts
## against walls unless [member through_walls] (the Clay Tablet falls through floors,
## like Symphony of the Night's axe). Drawn in code by [member style] until the art pass.

const SCENE_PATH: String = "res://scenes/actors/player/projectiles/player_shot.tscn"

## &"stone", &"tablet", &"bolt" or &"wave".
var style: StringName = &"stone"
var velocity: Vector2 = Vector2.ZERO
var fall_gravity: float = 0.0
## Keeps flying through enemies instead of breaking on the first hit.
var pierce: bool = false
var through_walls: bool = false
var size: Vector2 = Vector2(8, 8)
var color: Color = Color.WHITE
var attack: int = 10
var knockback: float = 140.0
var lifetime_frames: int = 150

var _frame: int = 0
var _done: bool = false

@onready var _hitbox: Hitbox = %Hitbox
@onready var _hit_shape: CollisionShape2D = %HitShape


## Group of the shots of [param arm] in flight, for its on-screen limit.
static func group_for(arm: RelicArmData) -> StringName:
	return StringName("relic_arm_" + String(arm.id))


## A new shot of [param shot_style]; set its fields, then [method launch] it.
static func create(shot_style: StringName) -> PlayerShot:
	var shot: PlayerShot = (load(SCENE_PATH) as PackedScene).instantiate() as PlayerShot
	shot.style = shot_style
	return shot


## Adds the shot under [param parent] at [param at] (global).
func launch(parent: Node, at: Vector2) -> PlayerShot:
	parent.add_child(self)
	global_position = at.round()
	reset_physics_interpolation()
	return self


func _ready() -> void:
	(_hit_shape.shape as RectangleShape2D).size = size
	_hitbox.owner_node = self
	_hitbox.attack = attack
	_hitbox.knockback = knockback
	_hitbox.hit_stop_frames = 2
	_hitbox.active = true
	_hitbox.hit_landed.connect(func(_hurtbox: Hurtbox, _info: DamageInfo) -> void:
		if not pierce:
			burst())
	if not through_walls:
		body_entered.connect(func(_body: Node2D) -> void: burst())


func _physics_process(delta: float) -> void:
	if _done:
		return
	_frame += 1
	velocity.y += fall_gravity * delta
	position += velocity * delta
	if _frame >= lifetime_frames:
		queue_free()
	queue_redraw()


## Breaks the shot with a spark.
func burst() -> void:
	if _done:
		return
	_done = true
	_hitbox.active = false
	HitSpark.spawn(get_tree(), global_position, color)
	queue_free()


func _draw() -> void:
	var facing: float = signf(velocity.x) if velocity.x != 0.0 else 1.0
	match style:
		&"stone":
			draw_rect(Rect2(-3, -3, 6, 6), color.darkened(0.4))
			draw_rect(Rect2(-2, -3, 4, 5), color)
			draw_rect(Rect2(-2, -2, 2, 2), color.lightened(0.4))
			for i: int in 3:
				draw_rect(Rect2(-facing * (6 + i * 4) - 1, -1, 2, 2), Color(color, 0.5 - i * 0.15))
		&"tablet":
			draw_set_transform(Vector2.ZERO, _frame * 0.35)
			draw_rect(Rect2(-size / 2.0, size), color.darkened(0.35))
			draw_rect(Rect2(-size / 2.0 + Vector2(1, 1), size - Vector2(2, 2)), color)
			for y: int in 3:
				draw_rect(Rect2(-size.x / 2.0 + 2, -size.y / 2.0 + 3 + y * 3, size.x - 4, 1), color.darkened(0.25))
		&"bolt":
			for i: int in 3:
				var t: float = float(i + 1)
				draw_rect(Rect2(-facing * (5.0 + t * 4.0) - 1.5, -1.5 + sin((_frame + i) * 0.8), 3, 3), Color(Color("c0263c"), 0.8 - t * 0.2))
			draw_rect(Rect2(-5, -4, 10, 8), Color("c0263c"))
			draw_rect(Rect2(-4, -3, 8, 6), color)
			draw_rect(Rect2(-2 + facing, -2, 4, 4), Color("fbe69b"))
		&"wave":
			var height: float = size.y + 3.0 * sin(_frame * 0.6)
			var points: PackedVector2Array = [Vector2(-facing * size.x / 2.0, size.y / 2.0),
					Vector2(facing * size.x / 2.0, size.y / 2.0), Vector2(facing * 2.0, size.y / 2.0 - height)]
			draw_colored_polygon(points, Color(color, 0.85))
			draw_line(points[2], points[1], color.lightened(0.5), 1.0)
