class_name AfterimageTrail
extends Node
## Leaves fading copies of the player's current frame while [member active], like
## Alucard's afterimages when he back-dashes (PLR-011). Ghosts live in the current scene,
## so they stay where they were drawn as the player moves on.

@export var interval_frames: int = 2
@export var lifetime_frames: int = 14
@export var tint: Color = Color(0.62, 0.5, 1.0, 0.55)

var active: bool = false:
	set(value):
		active = value
		_counter = 0

var _counter: int = 0


func _physics_process(_delta: float) -> void:
	if not active:
		return
	if _counter % interval_frames == 0:
		_spawn_ghost()
	_counter += 1


func _spawn_ghost() -> void:
	# Looked up here, not @onready: this node is ready before the Player sets its sprite.
	var source: Sprite2D = (owner as Player).sprite
	if source == null or source.texture == null:
		return
	var ghost: Ghost = Ghost.new()
	ghost.texture = source.texture
	ghost.centered = source.centered
	ghost.offset = source.offset
	ghost.hframes = source.hframes
	ghost.vframes = source.vframes
	ghost.frame_coords = source.frame_coords
	ghost.flip_h = source.flip_h
	ghost.modulate = tint
	ghost.lifetime_frames = lifetime_frames
	ghost.z_index = (owner as Node2D).z_index - 1
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	ghost.material = additive
	get_tree().current_scene.add_child(ghost)
	ghost.global_position = source.global_position
	ghost.reset_physics_interpolation()


## One fading copy.
class Ghost extends Sprite2D:
	var lifetime_frames: int = 14
	var _frame: int = 0
	var _start_alpha: float = 1.0

	func _ready() -> void:
		_start_alpha = modulate.a

	func _physics_process(_delta: float) -> void:
		_frame += 1
		modulate.a = _start_alpha * (1.0 - float(_frame) / lifetime_frames)
		if _frame >= lifetime_frames:
			queue_free()
