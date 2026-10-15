class_name SaveAltar
extends Area2D
## The altar of a Quiet Room (SAV-002): stand at it and press Up to restore HP and MP and
## save the game to SaveSystem.active_slot. The player then returns here after dying.

const PROMPT: String = "UP  SAVE"
const GOLD: Color = Color("d4b06e")

var _player_near: Player
var _cooldown: int = 0
var _glow_frames: int = 0


func _ready() -> void:
	body_entered.connect(func(body: Node2D) -> void:
		if body is Player:
			_player_near = body as Player)
	body_exited.connect(func(body: Node2D) -> void:
		if body == _player_near:
			_player_near = null)


func _physics_process(_delta: float) -> void:
	if _cooldown > 0:
		_cooldown -= 1
	if _glow_frames > 0:
		_glow_frames -= 1
	if _player_near != null and _cooldown == 0 and _player_near.is_on_floor() \
			and Input.is_action_just_pressed(&"move_up"):
		activate()
	queue_redraw()


## Restores the player and saves at this altar.
func activate() -> void:
	_cooldown = 60
	_glow_frames = 40
	Game.stats.full_restore()
	var room: Node = get_tree().get_first_node_in_group(&"room")
	var room_path: String = room.scene_file_path if room != null else ""
	var err: Error = SaveSystem.save_game(SaveSystem.active_slot, room_path, global_position)
	Events.notice.emit("GAME SAVED" if err == OK else "SAVE FAILED", "HP AND MP RESTORED")


func _draw() -> void:
	if _glow_frames > 0:
		var a: float = float(_glow_frames) / 40.0
		draw_rect(Rect2(-30, -66, 60, 66), Color(1.0, 0.85, 0.5, 0.25 * a))
	if _player_near != null and _cooldown == 0:
		var width: int = PixelFont.text_width(PROMPT)
		PixelFont.draw_text(self, Vector2(-floori(width / 2.0), -76), PROMPT, GOLD, 1, Color("0b0a10"))
