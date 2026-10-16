class_name EnemyShot
extends Area2D
## A plain enemy projectile built in code (BOSS-000): it flies with a velocity and
## optional gravity, hurts the player, bursts on walls and floors and after a while, and
## is drawn in code by [member style] until it has art. Styles: &"tear" (a falling drop
## of crimson), &"bolt" (a pale bolt of eye-light).

const LIFETIME_FRAMES: int = 240

var style: StringName = &"bolt"
var velocity: Vector2 = Vector2.ZERO
var fall_gravity: float = 0.0
var color: Color = Color("c0263c")
var _frame: int = 0
var _hitbox: Hitbox


## A new shot under [param parent] at [param at] (global), flying at [param shot_velocity]
## and hitting with [param power].
static func launch(parent: Node, at: Vector2, shot_style: StringName, shot_velocity: Vector2, power: int,
		gravity_amount: float = 0.0, tint: Color = Color("c0263c")) -> EnemyShot:
	var shot: EnemyShot = EnemyShot.new()
	shot.style = shot_style
	shot.velocity = shot_velocity
	shot.fall_gravity = gravity_amount
	shot.color = tint
	shot.z_index = 30
	# Its own body bursts on solid tiles (world, layer 1).
	shot.collision_layer = 0
	shot.collision_mask = 1
	shot.monitorable = false
	var wall_shape: CollisionShape2D = CollisionShape2D.new()
	var dot: CircleShape2D = CircleShape2D.new()
	dot.radius = 2.0
	wall_shape.shape = dot
	shot.add_child(wall_shape)
	# The hitbox: enemy_hitbox (layer 8) against player_hurtbox (layer 5).
	var hitbox: Hitbox = Hitbox.new()
	hitbox.collision_layer = 1 << 7
	hitbox.collision_mask = 1 << 4
	var hit_shape: CollisionShape2D = CollisionShape2D.new()
	var box: RectangleShape2D = RectangleShape2D.new()
	box.size = Vector2(8, 8)
	hit_shape.shape = box
	hitbox.add_child(hit_shape)
	hitbox.attack = power
	hitbox.knockback = 120.0
	hitbox.hit_stop_frames = 2
	shot.add_child(hitbox)
	shot._hitbox = hitbox
	parent.add_child(shot)
	shot.global_position = at.round()
	shot.reset_physics_interpolation()
	return shot


func _ready() -> void:
	_hitbox.owner_node = self
	_hitbox.active = true
	_hitbox.hit_landed.connect(func(_hurtbox: Hurtbox, _info: DamageInfo) -> void: burst())
	body_entered.connect(func(_body: Node2D) -> void: burst())


func _physics_process(delta: float) -> void:
	_frame += 1
	velocity.y += fall_gravity * delta
	position += velocity * delta
	if _frame >= LIFETIME_FRAMES:
		queue_free()
	queue_redraw()


## Breaks the shot with a spark.
func burst() -> void:
	if is_queued_for_deletion():
		return
	_hitbox.set_deferred(&"active", false)
	HitSpark.spawn(get_tree(), global_position, color)
	queue_free()


func _draw() -> void:
	match style:
		&"tear":
			draw_rect(Rect2(-1, -6, 2, 2), Color(color, 0.6))
			draw_rect(Rect2(-2, -4, 4, 4), color)
			draw_rect(Rect2(-3, -2, 6, 4), color)
			draw_rect(Rect2(-1, -2, 1, 2), Color("ef6a6a"))
		_:
			var trail: Vector2 = -velocity.normalized() * 3.0
			for i: int in 3:
				draw_rect(Rect2((trail * (i + 1)).round() - Vector2(1, 1), Vector2(2, 2)), Color(color, 0.5 - i * 0.15))
			draw_rect(Rect2(-3, -3, 6, 6), color)
			draw_rect(Rect2(-2, -2, 4, 4), Color("f0eef8"))
