@abstract
class_name Enemy
extends CharacterBody2D
## Base for every enemy (AI-001). Stats come from [member data]. Handles taking hits
## (damage numbers, white flash, stagger knockback, hit-stop), contact damage, death
## (fade, XP to the player, Events.enemy_killed). Subclasses implement [method _behave]
## and, until sprites exist, draw a placeholder in _draw().

const FLASH_FRAMES: int = 6
const STAGGER_FRAMES: int = 10
const DEATH_FRAMES: int = 30
const HIT_INVULNERABLE_FRAMES: int = 6

@export var data: EnemyData
@export var uses_gravity: bool = true
## Height of the visual above the origin (feet), for damage numbers.
@export var visual_height: float = 56.0

var facing: int = -1
var gravity: float = 1633.0

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
	var tint: Color = Color("fbe69b") if info.critical else Color.WHITE
	DamageNumber.spawn(get_tree(), global_position + Vector2(0, -visual_height), amount, tint, info.critical)
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
	Events.enemy_killed.emit(data.id, global_position)


func _update_dying() -> void:
	_dying_frames -= 1
	set_flash(1.0, Color("ef6a6a"))
	modulate.a = float(_dying_frames) / DEATH_FRAMES
	if _dying_frames <= 0:
		queue_free()
