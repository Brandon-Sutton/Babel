class_name CommandInput
extends RefCounted
## SPL-001: reads fighting-game style commands (Utterances, weapon arts) from the
## player's recent directional inputs. Only changes of direction are recorded, each with
## its physics frame, in screen terms; they are read relative to the facing at the moment
## of the attack press, because pressing back turns Elam around.
##
## Notation: comma-separated tokens F, B, U, D, UF, UB, DF, DB (F = forward, B = back),
## e.g. "D,DF,F" (fire bolts) or "B,F" (weapon arts). The attack press that completes the
## command is the caller's job.

## How many direction changes are kept.
const HISTORY_SIZE: int = 16
## The command's last direction counts if it was held or released at most this many
## frames before the attack press.
const FINAL_GRACE_FRAMES: int = 8


## One recorded direction change: screen direction (-1..1 each axis) from [member frame] on.
class Entry:
	var direction: Vector2i
	var frame: int

	func _init(p_direction: Vector2i, p_frame: int) -> void:
		direction = p_direction
		frame = p_frame


var _history: Array[Entry] = []


## Records the held direction for [param frame]; only changes are stored.
func record(direction: Vector2i, frame: int) -> void:
	if not _history.is_empty() and _history[-1].direction == direction:
		return
	_history.append(Entry.new(direction, frame))
	if _history.size() > HISTORY_SIZE:
		_history.remove_at(0)


func clear() -> void:
	_history.clear()


## True if [param command] was entered, ending at [param frame], within
## [param window_frames] from its first direction, read for [param facing] (1 or -1).
func matches(command: String, frame: int, facing: int, window_frames: int) -> bool:
	var tokens: PackedStringArray = command.replace(" ", "").split(",", false)
	if tokens.is_empty() or _history.is_empty():
		return false
	# Walk back through the history, matching tokens from the last one.
	var index: int = _history.size() - 1
	var token_index: int = tokens.size() - 1
	var first_frame: int = frame
	# The last token: the current direction, or one released just before the press.
	var found_last: bool = false
	while index >= 0:
		var entry: Entry = _history[index]
		var end_frame: int = _history[index + 1].frame if index + 1 < _history.size() else frame
		if frame - end_frame > FINAL_GRACE_FRAMES:
			return false
		if _token(entry.direction, facing) == tokens[token_index]:
			found_last = true
			first_frame = entry.frame
			break
		index -= 1
	if not found_last:
		return false
	token_index -= 1
	index -= 1
	while token_index >= 0 and index >= 0:
		var entry: Entry = _history[index]
		if frame - entry.frame > window_frames:
			return false
		if _token(entry.direction, facing) == tokens[token_index]:
			first_frame = entry.frame
			token_index -= 1
		index -= 1
	return token_index < 0 and frame - first_frame <= window_frames


## Recent inputs as notation for [param facing], oldest first (for the debug overlay).
func recent(facing: int, count: int = 6) -> String:
	var parts: PackedStringArray = []
	for i: int in range(maxi(0, _history.size() - count), _history.size()):
		var token: String = _token(_history[i].direction, facing)
		parts.append(token if not token.is_empty() else "N")
	return ",".join(parts)


## Notation token for a screen direction, relative to [param facing]; "" for neutral.
static func _token(direction: Vector2i, facing: int) -> String:
	var vertical: String = "U" if direction.y < 0 else ("D" if direction.y > 0 else "")
	var horizontal: String = ""
	if direction.x != 0:
		horizontal = "F" if signi(direction.x) == signi(facing) else "B"
	return vertical + horizontal
