@abstract
class_name Enemy
extends CharacterBody2D
## Base for every enemy (AI-001). Stats come from [member data]. Handles taking hits
## (damage numbers, white flash, stagger knockback, hit-stop), contact damage, death
## (fade, XP to the player, a roll of its loot table, Events.enemy_killed). Subclasses
## implement [method _behave]
## and, until sprites exist, draw a placeholder in _draw().

const FLASH_FRAMES: int = 6
const STAGGER_FRAMES: int = 10
const DEATH_FRAMES: int = 30
const HIT_INVULNERABLE_FRAMES: int = 6

@export var data: EnemyData
@export var uses_gravity: bool = true
## Height of the visual above the origin (feet), for damage numbers.
@export var visual_height: float = 56.0
## Folder with the imported sheet (<slug>.png, .json, _anims.tres). Empty = no sprite
## yet; the subclass's _draw() placeholder shows instead.
@export_dir var sprite_dir: String = ""
@export var sprite_slug: String = ""

var facing: int = -1
var gravity: float = 1633.0
## The sprite built from [member sprite_dir], or null while the placeholder is used.
var sprite: Sprite2D
var animation_player: AnimationPlayer

## Shared by every enemy's loot roll; [method seed_loot] makes drops repeatable.
static var _loot_rng: RandomNumberGenerator

var _stagger_frames: int = 0
var _knockback: float = 0.0
var _flash_frames: int = 0
var _dying_frames: int = -1

@onready var health: HealthComponent = %Health
@onready var hurtbox: Hurtbox = %Hurtbox
@onready var contact_hitbox: Hitbox = %ContactHitbox


func _ready() -> void:
	var flash_material: ShaderMaterial = ShaderMaterial.new()
	flash_material.shader = preload("res://assets/shaders/hit_flash.gdshader")
	material = flash_material
	health.reset(data.max_hp)
	health.died.connect(_on_died)
	hurtbox.owner_node = self
	hurtbox.handler = _on_hit
	contact_hitbox.owner_node = self
	contact_hitbox.continuous = true
	contact_hitbox.attack = data.attack
	contact_hitbox.knockback = 140.0
	contact_hitbox.active = data.contact_damage
	_setup_sprite()


func _setup_sprite() -> void:
	if sprite_dir.is_empty() or sprite_slug.is_empty():
		return
	var json_path: String = sprite_dir.path_join(sprite_slug + ".json")
	if not FileAccess.file_exists(json_path):
		push_warning("Enemy: no sprite sheet at %s" % json_path)
		return
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(json_path))
	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = load(sprite_dir.path_join(sprite_slug + ".png"))
	sprite.centered = false
	sprite.hframes = int(layout["columns"])
	sprite.vframes = int(layout["rows"])
	var pivot: Array = layout["pivot"]
	sprite.offset = -Vector2(float(pivot[0]), float(pivot[1]))
	sprite.use_parent_material = true
	add_child(sprite)
	animation_player = AnimationPlayer.new()
	add_child(animation_player)
	animation_player.add_animation_library(&"", load(sprite_dir.path_join(sprite_slug + "_anims.tres")))
	play_animation(&"idle")


## Plays [param animation_name] if the sprite has it (no-op on the placeholder). A
## finished non-looping animation holds its last frame; [param restart] replays it.
func play_animation(animation_name: StringName, restart: bool = false) -> void:
	if animation_player == null or not animation_player.has_animation(animation_name):
		return
	if restart or animation_player.assigned_animation != animation_name:
		animation_player.play(animation_name)
		animation_player.seek(0.0, true)


func _physics_process(delta: float) -> void:
	if _dying_frames >= 0:
		_update_dying()
		return
	if _flash_frames > 0:
		_flash_frames -= 1
		set_flash(float(_flash_frames) / FLASH_FRAMES)
	if _stagger_frames > 0:
		_stagger_frames -= 1
		velocity.x = _knockback
		_knockback = move_toward(_knockback, 0.0, 18.0)
	else:
		_behave(delta)
	if uses_gravity:
		velocity.y = minf(velocity.y + gravity * delta, 800.0)
	move_and_slide()
	if sprite != null:
		sprite.flip_h = facing < 0
	else:
		queue_redraw()


## Per-frame behaviour while alive and not staggered: set velocity and facing.
@abstract func _behave(delta: float) -> void


## Called after a hit was accepted (override for reactions such as cancelling attacks).
func _on_damaged(_info: DamageInfo, _staggered: bool) -> void:
	pass


func is_dying() -> bool:
	return _dying_frames >= 0


func is_staggered() -> bool:
	return _stagger_frames > 0


## The player, or null if there is none.
func target() -> Player:
	return get_tree().get_first_node_in_group(&"player") as Player


## True if the player is alive, within aggro range horizontally and roughly level.
func target_in_range() -> bool:
	var player: Player = target()
	if player == null or Game.stats.is_dead():
		return false
	var offset: Vector2 = player.global_position - global_position
	return absf(offset.x) <= data.aggro_range and absf(offset.y) <= 96.0


## Blends the visual toward [param color] by [param amount] (0..1).
func set_flash(amount: float, color: Color = Color.WHITE) -> void:
	var flash_material: ShaderMaterial = material as ShaderMaterial
	flash_material.set_shader_parameter(&"flash", clampf(amount, 0.0, 1.0))
	flash_material.set_shader_parameter(&"flash_color", color)


func _on_hit(info: DamageInfo) -> bool:
	if is_dying():
		return false
	var amount: int = Combat.damage(info.attack, data.defense, info.critical)
	if not health.apply_damage(amount, info, HIT_INVULNERABLE_FRAMES):
		return false
	info.dealt = amount
	var tint: Color = Color("fbe69b") if info.critical else Color.WHITE
	DamageNumber.spawn(get_tree(), global_position + Vector2(0, -visual_height), amount, tint, info.critical)
	HitSpark.spawn(get_tree(), info.position, Color("fbe69b"), info.critical)
	if info.critical:
		GameCamera.shake(get_tree(), 2.0, 6)
	_flash_frames = FLASH_FRAMES
	set_flash(1.0)
	var staggered: bool = amount >= data.poise
	if staggered and health.is_alive():
		_stagger_frames = STAGGER_FRAMES
		_knockback = info.direction * info.knockback
	HitStop.trigger(get_tree(), info.hit_stop_frames)
	_on_damaged(info, staggered)
	return true


func _on_died() -> void:
	_dying_frames = DEATH_FRAMES
	contact_hitbox.active = false
	hurtbox.set_deferred(&"monitorable", false)
	collision_layer = 0
	velocity = Vector2.ZERO
	Game.stats.add_xp(data.xp)
	_drop_loot()
	Events.enemy_killed.emit(data.id, global_position)
	GameCamera.shake(get_tree(), 2.0, 8)


## Makes the following loot rolls repeatable (tests).
static func seed_loot(value: int) -> void:
	_loot_rng = RandomNumberGenerator.new()
	_loot_rng.seed = value


## The random generator loot rolls use.
static func loot_rng() -> RandomNumberGenerator:
	if _loot_rng == null:
		_loot_rng = RandomNumberGenerator.new()
		_loot_rng.randomize()
	return _loot_rng


func _drop_loot() -> void:
	if data.loot == null:
		return
	var drop: LootTable.Drop = data.loot.roll(loot_rng(), Game.stats.total(&"luck"))
	Pickup.spawn(get_parent(), global_position + Vector2(0, -visual_height * 0.5), drop)


func _update_dying() -> void:
	_dying_frames -= 1
	set_flash(1.0, Color("ef6a6a"))
	modulate.a = float(_dying_frames) / DEATH_FRAMES
	if _dying_frames <= 0:
		queue_free()
