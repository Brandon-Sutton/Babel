class_name Fireball
extends Area2D
## Fireball hurled by the Gate Spearman (ENM-007). Leaves the hand, climbs a few pixels
## so it visibly clears a crouching player's head, then flies level. Hurts the player on
## contact, bursts against walls, and can be cut down with a weapon (its Hurtbox sits on
## the enemy_hurtbox layer). The sprite is the fireball painted in the spearman's cast
## animation (frame 5), so the hand-off from the cast frame is seamless.

const SPEED: float = 170.0
const LIFETIME_FRAMES: int = 240
## Climb after launch: CLIMB_PX over the first CLIMB_FRAMES, then level flight.
const CLIMB_PX: float = 9.0
const CLIMB_FRAMES: int = 12
## The fireball's core in sprite pixels; it sits on the node origin.
const CORE: Vector2 = Vector2(25, 9)
const EMBER: Color = Color("df9161")
const OUTER: Color = Color("c0263c")

## -1 flies left, 1 right.
var direction: float = 1.0
var attack: int = 10
var _frame: int = 0
var _bursting: bool = false

@onready var _sprite: Sprite2D = %Sprite
@onready var _hitbox: Hitbox = %Hitbox
@onready var _hurtbox: Hurtbox = %Hurtbox


## Launches a fireball whose core starts at [param at] (global) under [param parent].
static func launch(parent: Node, at: Vector2, facing: float, power: int) -> Fireball:
	var fireball: Fireball = (load("res://scenes/actors/enemies/projectiles/fireball.tscn") as PackedScene).instantiate() as Fireball
	fireball.direction = facing
	fireball.attack = power
	parent.add_child(fireball)
	fireball.global_position = at
	# Otherwise the first frame is interpolated from the origin and the flame blinks out.
	fireball.reset_physics_interpolation()
	return fireball


func _ready() -> void:
	body_entered.connect(func(_body: Node2D) -> void: burst())
	_sprite.flip_h = direction < 0.0
	var width: float = _sprite.texture.get_width()
	_sprite.offset = -Vector2(CORE.x if direction > 0.0 else width - CORE.x, CORE.y)
	_hitbox.owner_node = self
	_hitbox.attack = attack
	_hitbox.knockback = 120.0
	_hitbox.hit_stop_frames = 2
	_hitbox.active = true
	_hitbox.hit_landed.connect(func(_hurtbox_hit: Hurtbox, _info: DamageInfo) -> void: burst())
	_hurtbox.owner_node = self
	_hurtbox.handler = func(_info: DamageInfo) -> bool:
		burst()
		return true


func _physics_process(delta: float) -> void:
	if _bursting:
		return
	position.x += direction * SPEED * delta
	_frame += 1
	if _frame <= CLIMB_FRAMES:
		position.y -= CLIMB_PX / CLIMB_FRAMES
	# Flicker: the flame flips top-to-bottom every few frames.
	_sprite.flip_v = _frame % 8 >= 4
	if _frame >= LIFETIME_FRAMES:
		queue_free()
	queue_redraw()


## Pops the fireball (wall, player or a sword stroke).
func burst() -> void:
	if _bursting:
		return
	_bursting = true
	_hitbox.active = false
	HitSpark.spawn(get_tree(), global_position, EMBER, true)
	queue_free()


func _draw() -> void:
	# Embers shed behind the tail of the flame.
	for i: int in 3:
		var t: float = float(i + 1)
		var at: Vector2 = Vector2(-direction * (26.0 + t * 5.0), roundf(sin((_frame + i * 3) * 0.6) * 2.0))
		var size: float = 4.0 - t
		draw_rect(Rect2(at - Vector2(size, size) / 2.0, Vector2(size, size)), Color(OUTER, 1.0 - t * 0.25))
