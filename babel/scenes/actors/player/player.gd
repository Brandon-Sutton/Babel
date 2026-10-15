class_name Player
extends CharacterBody2D
## The player character (PLR-001). Actions live in the StateMachine's states (states/);
## this script owns what they share: input helpers, jump buffer and coyote time,
## facing, crouch shapes, one-way drop-through, the weapon hitbox, taking hits,
## invulnerability flicker and animation playback. Origin is at the feet.

## Emitted after the death sequence; the main scene respawns the player.
signal respawn_requested

const STAND_HEIGHT: float = 80.0
const CROUCH_HEIGHT: float = 50.0
const BODY_RADIUS: float = 10.0
## Colour of the sparks a swing strikes off stone.
const WALL_SPARK: Color = Color("d8d0c0")
const WORLD_BIT: int = 1 << 0
const PLATFORM_BIT: int = 1 << 1

@export var tuning: PlayerTuning
## Folder with the imported sheet: <slug>.png, <slug>.json and <slug>_anims.tres.
@export_dir var sprite_dir: String = "res://assets/sprites/player/hero"
@export var sprite_slug: String = "hero"

var facing: int = 1
## Frames left in which a jump press still counts.
var jump_buffer: int = 0
## Frames left in which a jump from the ground still counts after leaving it.
var coyote: int = 0
var air_jumps_left: int = 0
var invulnerable_frames: int = 0
var backdash_cooldown: int = 0
var crouching: bool = false
## Direction of the last hit taken (the player is pushed this way).
var knockback_direction: float = 1.0

var _drop_through_frames: int = 0

@onready var sprite: Sprite2D = %Sprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var machine: StateMachine = %StateMachine
@onready var hurtbox: Hurtbox = %Hurtbox
@onready var weapon_hitbox: Hitbox = %WeaponHitbox
@onready var slash_fx: SlashFX = %SlashFX
@onready var camera: GameCamera = %Camera
@onready var afterimages: AfterimageTrail = %Afterimages
## Draws the equipped items and relics on the body (EQV-005).
@onready var equipment_rig: EquipmentRig = %EquipmentRig
@onready var _body_shape: CollisionShape2D = %BodyShape
@onready var _hurt_shape: CollisionShape2D = %HurtShape
@onready var _weapon_shape: CollisionShape2D = %WeaponShape


func _ready() -> void:
	add_to_group(&"player")
	hurtbox.owner_node = self
	hurtbox.handler = take_hit
	weapon_hitbox.owner_node = self
	Game.stats.leveled_up.connect(_on_leveled_up)
	_setup_sprite()
	set_crouching(false)
	# Entered here, not via StateMachine.initial_state: states need this node's
	# @onready references, which exist only once this _ready runs.
	machine.transition_to(&"Ground")


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(&"jump"):
		jump_buffer = tuning.jump_buffer_frames
	elif jump_buffer > 0:
		jump_buffer -= 1
	machine.physics_update(delta)
	move_and_slide()
	if is_on_floor():
		coyote = tuning.coyote_frames
		air_jumps_left = 1 if Game.has_ability(&"double_jump") else 0
	elif coyote > 0:
		coyote -= 1
	_tick_timers()


## Horizontal input as -1, 0 or 1.
func input_x() -> float:
	return signf(Input.get_axis(&"move_left", &"move_right"))


## Turns toward [param direction] (ignored when 0).
func face(direction: float) -> void:
	if direction == 0.0:
		return
	facing = 1 if direction > 0.0 else -1
	sprite.flip_h = facing < 0


func apply_gravity(delta: float) -> void:
	velocity.y = minf(velocity.y + tuning.gravity() * delta, tuning.max_fall_speed)


## Uses up a buffered jump press. Returns true if there was one.
func consume_jump() -> bool:
	if jump_buffer <= 0:
		return false
	jump_buffer = 0
	return true


func can_ground_jump() -> bool:
	return is_on_floor() or coyote > 0


func jump() -> void:
	velocity.y = -tuning.jump_velocity()
	coyote = 0


func double_jump() -> void:
	velocity.y = -tuning.double_jump_velocity()
	air_jumps_left -= 1


## True when standing on a one-way platform rather than solid ground.
func on_one_way_platform() -> bool:
	if not is_on_floor():
		return false
	var saved: int = collision_mask
	collision_mask = WORLD_BIT
	var solid_below: bool = test_move(global_transform, Vector2(0, 2))
	collision_mask = saved
	return not solid_below


## Drops through the one-way platform underfoot.
func drop_through() -> void:
	_drop_through_frames = tuning.drop_through_frames
	collision_mask &= ~PLATFORM_BIT
	position.y += 2.0


## Switches the body and hurtbox between standing and crouching heights.
func set_crouching(value: bool) -> void:
	crouching = value
	var height: float = CROUCH_HEIGHT if value else STAND_HEIGHT
	var capsule: CapsuleShape2D = _body_shape.shape as CapsuleShape2D
	capsule.height = height
	_body_shape.position.y = -height / 2.0
	var hurt_rect: RectangleShape2D = _hurt_shape.shape as RectangleShape2D
	hurt_rect.size = Vector2(18.0, height - 4.0)
	_hurt_shape.position.y = -height / 2.0


## Activates the weapon hitbox in front of the player for [param weapon]. The placeholder
## arc shows only when [param show_arc] is set (the animation has no swing art yet).
func start_attack(weapon: WeaponData, low: bool, show_arc: bool) -> void:
	var rect: RectangleShape2D = _weapon_shape.shape as RectangleShape2D
	rect.size = Vector2(weapon.reach, weapon.hitbox_height)
	weapon_hitbox.position = Vector2(facing * (BODY_RADIUS + weapon.reach / 2.0), -22.0 if low else -50.0)
	weapon_hitbox.attack = Game.stats.attack_power()
	weapon_hitbox.knockback = weapon.knockback
	weapon_hitbox.hit_stop_frames = weapon.hit_stop_frames
	weapon_hitbox.crit_chance = Combat.crit_chance(Game.stats.luck)
	weapon_hitbox.active = true
	if show_arc:
		slash_fx.play(weapon, facing, low)
	_spark_on_wall(weapon, weapon_hitbox.position.y)


## A swing that meets a wall within its reach strikes sparks there (CBT-013): the wall
## also stops the hit, so this shows why an enemy behind it was not touched.
func _spark_on_wall(weapon: WeaponData, height: float) -> void:
	var origin: Vector2 = global_position + Vector2(0.0, height)
	var tip: Vector2 = origin + Vector2(facing * (BODY_RADIUS + weapon.reach), 0.0)
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(origin, tip, Hitbox.WORLD_MASK)
	var hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		HitSpark.spawn(get_tree(), hit["position"], WALL_SPARK)


func stop_attack() -> void:
	weapon_hitbox.active = false


## Hurtbox handler: applies a hit unless invulnerable or dead. Returns whether it counted.
func take_hit(info: DamageInfo) -> bool:
	if invulnerable_frames > 0 or machine.current_name() == &"Dead":
		return false
	var amount: int = Combat.damage(info.attack, Game.stats.defense(), info.critical)
	DamageNumber.spawn(get_tree(), global_position + Vector2(0, -STAND_HEIGHT), amount, Color("ef6a6a"))
	invulnerable_frames = tuning.invulnerable_frames
	knockback_direction = info.direction
	HitStop.trigger(get_tree(), 3)
	HitSpark.spawn(get_tree(), global_position + Vector2(0, -STAND_HEIGHT / 2.0), Color("ef6a6a"))
	GameCamera.shake(get_tree(), 3.0, 12)
	if Game.stats.take_damage(amount) <= 0:
		machine.transition_to(&"Dead")
	else:
		machine.transition_to(&"Hurt")
	return true


## The animation that plays for [param animation_name]: the equipped weapon's version
## (its own move, then its stance set, e.g. two_handed_jump; EQV-015/016) when the sheet
## has one, else the shared one-handed animation.
func resolve_animation(animation_name: StringName) -> StringName:
	var weapon: WeaponData = Game.stats.weapon
	if weapon != null:
		for candidate: StringName in weapon.animation_candidates(animation_name):
			if animation_player.has_animation(candidate):
				return candidate
	return animation_name


## Plays [param animation_name] (or the weapon's version of it), falling back to idle if
## the sheet doesn't have it yet. A finished non-looping animation (crouch, jump) holds
## its last frame rather than restarting; pass [param restart] to play it again.
func play_animation(animation_name: StringName, restart: bool = false) -> void:
	var name_to_play: StringName = resolve_animation(animation_name)
	if not animation_player.has_animation(name_to_play):
		name_to_play = resolve_animation(&"idle")
	if not animation_player.has_animation(name_to_play):
		return
	if restart or animation_player.assigned_animation != name_to_play:
		animation_player.play(name_to_play)
		animation_player.seek(0.0, true)


## Shows the last frame of [param animation_name] (e.g. already crouched).
func hold_last_frame(animation_name: StringName) -> void:
	var name_to_play: StringName = resolve_animation(animation_name)
	if not animation_player.has_animation(name_to_play):
		return
	animation_player.play(name_to_play)
	animation_player.seek(animation_player.current_animation_length, true)


## Puts the player back at [param at] after death or a room change.
func respawn_at(at: Vector2) -> void:
	global_position = at
	velocity = Vector2.ZERO
	sprite.modulate = Color.WHITE
	invulnerable_frames = 60
	machine.transition_to(&"Ground")
	reset_physics_interpolation()


func _on_leveled_up(_new_level: int) -> void:
	DamageNumber.spawn_text(get_tree(), global_position + Vector2(0, -STAND_HEIGHT - 12.0), "LEVEL UP",
			Color("fbe69b"), 2, 90)


func _tick_timers() -> void:
	if backdash_cooldown > 0:
		backdash_cooldown -= 1
	if _drop_through_frames > 0:
		_drop_through_frames -= 1
		if _drop_through_frames == 0:
			collision_mask |= PLATFORM_BIT
	if invulnerable_frames > 0:
		invulnerable_frames -= 1
		# Flicker while invulnerable (not during the death sequence).
		var dim: bool = invulnerable_frames > 0 and floori(invulnerable_frames / 3.0) % 2 == 0
		if machine.current_name() != &"Dead":
			sprite.modulate.a = 0.35 if dim else 1.0


func _setup_sprite() -> void:
	var json_path: String = sprite_dir.path_join(sprite_slug + ".json")
	if not FileAccess.file_exists(json_path):
		push_warning("Player: no sprite sheet at %s" % json_path)
		return
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(json_path))
	sprite.texture = load(sprite_dir.path_join(sprite_slug + ".png"))
	sprite.centered = false
	sprite.hframes = int(layout["columns"])
	sprite.vframes = int(layout["rows"])
	var pivot: Array = layout["pivot"]
	sprite.offset = -Vector2(float(pivot[0]), float(pivot[1]))
	animation_player.add_animation_library(&"", load(sprite_dir.path_join(sprite_slug + "_anims.tres")))
	var smear_path: String = sprite_dir.path_join(sprite_slug + "_smear.png")
	equipment_rig.setup(sprite, layout, load(smear_path) as Texture2D if ResourceLoader.exists(smear_path) else null)
