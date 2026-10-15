class_name WorldKeys
extends RefCounted
## Persistence keys for one-time world objects (CLAUDE.md "Persistence keys"): a broken
## wall, a found secret or an opened chest saves as "<room_id>/<name>" in Game.flags.


## The id of the room [param node] is in: the nearest ancestor in the "room" group (or
## the current scene) gives its [code]room_id[/code] property if it has one, else its
## scene file's name, else its node name.
static func room_id(node: Node) -> String:
	var room: Node = node
	while room != null and not room.is_in_group(&"room"):
		room = room.get_parent()
	if room == null and node.is_inside_tree():
		room = node.get_tree().current_scene
	if room == null:
		return "room"
	var id: Variant = room.get(&"room_id")
	if (id is String or id is StringName) and not String(id).is_empty():
		return String(id)
	if not room.scene_file_path.is_empty():
		return room.scene_file_path.get_file().get_basename()
	return String(room.name)


## The flag for [param local_name] in the room [param node] is in.
static func key(node: Node, local_name: String) -> StringName:
	return StringName("%s/%s" % [room_id(node), local_name])
