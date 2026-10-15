extends Enemy
## Gate Spearman (ENM-007): shade of a Babylonian gate guard. Advances on the player,
## telegraphs with a gold flash, then lunges with a spear thrust. Hitting it during the
## wind-up (with a staggering hit) cancels the thrust. Sprite: PixelLab character
## 34128d92 (ART-003); the thrust animation is split into windup, thrust and recover.

enum Mode { ADVANCE, WINDUP, THRUST, RECOVER }

const ATTACK_RANGE: float = 72.0
const WINDUP_FRAMES: int = 28
const THRUST_FRAMES: int = 8
const RECOVER_FRAMES: int = 36
const LUNGE_SPEED: float = 90.0
const ARMOR: Color = Color("2e2939")
const ARMOR_LIGHT: Color = Color("4b3d6e")
const LAPIS: Color = Color("2c4a9a")
const GOLD: Color = Color("c59c5c")
const SHAFT: Color = Color("82633f")

var mode: Mode = Mode.ADVANCE
var _timer: int = 0

@onready var _spear: Hitbox = %SpearHitbox


func _ready() -> void:
	super._ready()
	_spear.owner_node = self
	_spear.attack = data.attack + 4
	_spear.knockback = 180.0
	_spear.hit_stop_frames = 3


func _behave(_delta: float) -> void:
	match mode:
		Mode.ADVANCE:
			var player: Player = target()
			if not target_in_range():
				velocity.x = 0.0
				play_animation(&"idle")
				return
			var dx: float = player.global_position.x - global_position.x
			facing = 1 if dx > 0.0 else -1
			if absf(dx) <= ATTACK_RANGE:
				_start(Mode.WINDUP, WINDUP_FRAMES)
				velocity.x = 0.0
			else:
				velocity.x = facing * data.move_speed
				play_animation(&"walk")
		Mode.WINDUP:
			velocity.x = 0.0
			set_flash(0.25 + 0.35 * float(_timer % 8 < 4), Color("fbe69b"))
			_timer -= 1
			if _timer <= 0:
				set_flash(0.0)
				_spear.position.x = facing * 44.0
				_spear.active = true
				velocity.x = facing * LUNGE_SPEED
				_start(Mode.THRUST, THRUST_FRAMES)
		Mode.THRUST:
			velocity.x = move_toward(velocity.x, 0.0, 12.0)
			_timer -= 1
			if _timer <= 0:
				_spear.active = false
				_start(Mode.RECOVER, RECOVER_FRAMES)
		Mode.RECOVER:
			velocity.x = 0.0
			_timer -= 1
			if _timer <= 0:
				mode = Mode.ADVANCE


func _on_damaged(_info: DamageInfo, staggered: bool) -> void:
	if staggered and mode == Mode.WINDUP:
		set_flash(1.0)
		_start(Mode.RECOVER, RECOVER_FRAMES)


func _on_died() -> void:
	_spear.active = false
	super._on_died()


func _start(next: Mode, frames: int) -> void:
	mode = next
	_timer = frames
	var animations: Dictionary[Mode, StringName] = {
		Mode.WINDUP: &"windup", Mode.THRUST: &"thrust", Mode.RECOVER: &"recover",
	}
	if animations.has(next):
		play_animation(animations[next])


func _draw() -> void:
	if sprite != null:
		return
	draw_rect(Rect2(-9, -66, 18, 50), ARMOR)
	draw_rect(Rect2(-9, -66, 18, 3), ARMOR_LIGHT)
	draw_rect(Rect2(-7, -16, 6, 16), ARMOR)
	draw_rect(Rect2(1, -16, 6, 16), ARMOR)
	draw_rect(Rect2(-8, -80, 16, 14), ARMOR_LIGHT)
	draw_rect(Rect2(-8, -84, 16, 4), GOLD)
	draw_rect(Rect2(-facing * 4 - 2, -92, 4, 8), LAPIS)
	draw_rect(Rect2(facing * 3 - 1, -74, 3, 2), GOLD)
	var reach: float = 56.0 if mode == Mode.THRUST else (8.0 if mode == Mode.WINDUP else 26.0)
	var y: float = -48.0
	draw_line(Vector2(-facing * 18.0, y), Vector2(facing * reach, y), SHAFT, 2.0)
	draw_rect(Rect2(facing * reach - (0.0 if facing > 0 else 6.0), y - 2, 6, 4), GOLD)
