@tool
class_name BossArena
extends Node2D
## Where a boss is fought (BOSS-000). When Elam steps into [member trigger], the arena
## locks: gates drop across [member gates], the camera pans to frame [member area], the
## boss announces itself (name card, HP bar), and after [member start_delay_frames] it
## begins. When the boss is defeated the gates rise, the camera pans back to the room's
## bounds and the flag "<room_id>/<node name>" is saved, so a defeated boss is gone (and
## its gates open) when the room loads again. Rectangles are in this node's coordinates
## and show in the editor.

const GATE_FRAMES: int = 18
const IRON: Color = Color("2e2939")
const IRON_LIGHT: Color = Color("5a5266")
const RUST: Color = Color("7a4a22")

enum ArenaState { IDLE, LOCKED, DONE }

## The boss fought here.
@export var boss: Boss
## The camera's view during the fight (at least one screen).
@export var area: Rect2 = Rect2(0, 0, 640, 360):
	set(value):
		area = value
		queue_redraw()
## Stepping in here starts the fight.
@export var trigger: Rect2 = Rect2(64, 0, 512, 360):
	set(value):
		trigger = value
		queue_redraw()
## Solid while the fight lasts.
@export var gates: Array[Rect2] = []:
	set(value):
		gates = value
		queue_redraw()
## Frames between the arena locking (name card) and the boss acting.
@export var start_delay_frames: int = 70
@export var pan_seconds: float = 0.5

var state: ArenaState = ArenaState.IDLE
var _delay: int = 0
## 0 while open, GATE_FRAMES once fully closed.
var _gate_drop: int = 0
var _gate_bodies: Array[StaticBody2D] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	z_index = 5
	if Game.is_flag(flag()):
		state = ArenaState.DONE
		if boss != null:
			boss.queue_free()
			boss = null
		return
	if boss != null:
		boss.defeated.connect(_on_boss_defeated)


## The world flag saved when the boss is defeated.
func flag() -> StringName:
	return WorldKeys.key(self, String(name))


## True while the gates are closed.
func is_locked() -> bool:
	return state == ArenaState.LOCKED


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	match state:
		ArenaState.IDLE:
			var player: Player = get_tree().get_first_node_in_group(&"player") as Player
			if player != null and boss != null and _global(trigger).has_point(player.global_position + Vector2(0, -2)):
				_lock(player)
		ArenaState.LOCKED:
			_gate_drop = mini(GATE_FRAMES, _gate_drop + 1)
			if _delay > 0:
				_delay -= 1
				if _delay == 0 and is_instance_valid(boss):
					boss.begin()
		ArenaState.DONE:
			_gate_drop = maxi(0, _gate_drop - 1)
			if _gate_drop == 0 and not _gate_bodies.is_empty():
				for body: StaticBody2D in _gate_bodies:
					body.queue_free()
				_gate_bodies.clear()
	queue_redraw()


func _lock(player: Player) -> void:
	state = ArenaState.LOCKED
	_delay = start_delay_frames
	for rect: Rect2 in gates:
		var body: StaticBody2D = StaticBody2D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		var shape: CollisionShape2D = CollisionShape2D.new()
		var box: RectangleShape2D = RectangleShape2D.new()
		box.size = rect.size
		shape.shape = box
		shape.position = rect.get_center()
		body.add_child(shape)
		add_child(body)
		_gate_bodies.append(body)
	CameraLimits.pan(self, player.camera, _global(area), pan_seconds)
	GameCamera.shake(get_tree(), 2.0, 10)
	boss.announce()


func _on_boss_defeated() -> void:
	state = ArenaState.DONE
	Game.set_flag(flag())
	var player: Player = get_tree().get_first_node_in_group(&"player") as Player
	var bounds: Rect2 = CameraLimits.room_bounds(self)
	if player != null and bounds.has_area():
		CameraLimits.pan(self, player.camera, bounds, pan_seconds)


func _global(rect: Rect2) -> Rect2:
	return Rect2(to_global(rect.position), rect.size)


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(area, Color(1.0, 0.4, 0.3, 0.6), false, 1.0)
		draw_rect(trigger, Color(1.0, 0.8, 0.3, 0.6), false, 1.0)
		for rect: Rect2 in gates:
			draw_rect(rect, Color(0.7, 0.7, 0.8, 0.6), false, 1.0)
		return
	if _gate_drop == 0:
		return
	# Portcullis gates: iron bars sliding down from the top of each gate.
	var t: float = float(_gate_drop) / GATE_FRAMES
	for rect: Rect2 in gates:
		var height: float = roundf(rect.size.y * t)
		var top: float = rect.position.y
		for x: int in range(int(rect.position.x), int(rect.end.x), 5):
			draw_rect(Rect2(x, top, 3, height), IRON)
			draw_rect(Rect2(x, top, 1, height), IRON_LIGHT)
		for y: int in range(int(top) + 6, int(top + height), 12):
			draw_rect(Rect2(rect.position.x, y, rect.size.x, 2), RUST)
		draw_rect(Rect2(rect.position.x, top + height - 3, rect.size.x, 3), IRON_LIGHT)
