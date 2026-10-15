extends Node
## Versioned JSON save files in [code]user://saves/[/code] (SAV-001). Saves are never
## Godot Resources: loading a .tres/.res from user:// can execute embedded scripts.
## Writes go to a temp file that then replaces the save, and the previous save is kept
## as .bak (SAV-006).

const SAVE_VERSION: int = 1
const SAVE_DIR: String = "user://saves"
const SLOT_COUNT: int = 3
const STAT_FIELDS: PackedStringArray = [
	"level", "xp", "strength", "constitution", "intelligence", "luck",
	"max_hp", "max_mp", "hp", "mp", "embers", "max_embers", "shekels",
]

## Slot the game saves to and continues from.
var active_slot: int = 0


## Returns the file path for save [param slot].
func slot_path(slot: int) -> String:
	return SAVE_DIR.path_join("slot_%d.json" % slot)


## Returns true if save [param slot] exists on disk.
func has_save(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))


## Writes the current run (Game) to [param slot], recording where to resume.
func save_game(slot: int, room_path: String, position: Vector2) -> Error:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIR))
	var text: String = JSON.stringify(build_save(room_path, position), "\t")
	var path: String = slot_path(slot)
	var temp_path: String = path + ".tmp"
	var file: FileAccess = FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(text)
	file.close()
	if FileAccess.file_exists(path):
		DirAccess.copy_absolute(path, path + ".bak")
		DirAccess.remove_absolute(path)
	return DirAccess.rename_absolute(temp_path, path)


## Reads [param slot]. Returns an empty dictionary if it's missing or unreadable.
func load_game(slot: int) -> Dictionary:
	if not has_save(slot):
		return {}
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(slot_path(slot))) != OK or not json.data is Dictionary:
		push_error("SaveSystem: %s is not a valid save." % slot_path(slot))
		return {}
	return migrate(json.data)


## Deletes save [param slot] (and its backup).
func delete_save(slot: int) -> void:
	for path: String in [slot_path(slot), slot_path(slot) + ".bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


## The current run as a save dictionary.
func build_save(room_path: String, position: Vector2) -> Dictionary:
	var stats: Dictionary = {}
	for field: String in STAT_FIELDS:
		stats[field] = Game.stats.get(field)
	var equipped: Dictionary = {}
	for slot: StringName in Game.stats.equipped:
		equipped[String(slot)] = String(Game.stats.equipped[slot].id)
	var abilities: Array[String] = []
	for ability: StringName in Game.abilities:
		abilities.append(String(ability))
	var flags: Dictionary = {}
	for flag: StringName in Game.flags:
		flags[String(flag)] = Game.flags[flag]
	var spells: Array[String] = []
	for spell_id: StringName in Game.spells:
		spells.append(String(spell_id))
	return {
		"version": SAVE_VERSION,
		"saved_unix": Time.get_unix_time_from_system(),
		"play_time": Game.play_time,
		"room": room_path,
		"position": [position.x, position.y],
		"stats": stats,
		"equipped": equipped,
		"inventory": Game.inventory.to_dict(),
		"abilities": abilities,
		"flags": flags,
		"relic_arm": String(Game.stats.relic_arm.id) if Game.stats.relic_arm != null else "",
		"spells": spells,
		"map": WorldMap.save_data(),
	}


## Replaces the current run (Game) with [param data]. Unknown keys are ignored.
func apply_save(data: Dictionary) -> void:
	Game.reset()
	for slot: StringName in PlayerStats.SLOTS:
		Game.stats.equip(slot, null)
	var stats: Dictionary = data.get("stats", {})
	for field: String in STAT_FIELDS:
		if stats.has(field):
			Game.stats.set(field, int(stats[field]))
	var equipped: Dictionary = data.get("equipped", {})
	for slot: Variant in equipped:
		var equipment: EquipmentData = Game.item(StringName(str(equipped[slot]))) as EquipmentData
		if equipment != null:
			Game.stats.equip(StringName(str(slot)), equipment)
	Game.inventory.load_dict(data.get("inventory", {}))
	for ability: Variant in data.get("abilities", []):
		Game.grant_ability(StringName(str(ability)))
	var flags: Dictionary = data.get("flags", {})
	for flag: Variant in flags:
		Game.flags[StringName(str(flag))] = bool(flags[flag])
	var relic_arm_id: String = str(data.get("relic_arm", ""))
	Game.stats.relic_arm = Game.item(StringName(relic_arm_id)) as RelicArmData if not relic_arm_id.is_empty() else null
	if data.has("spells"):
		Game.spells.clear()
		for spell_id: Variant in data["spells"]:
			Game.learn_spell(StringName(str(spell_id)))
	Game.play_time = float(data.get("play_time", 0.0))
	WorldMap.load_data(data.get("map", {}))


## Where a save resumes: its position as a Vector2 (ZERO if missing).
func saved_position(data: Dictionary) -> Vector2:
	var pair: Array = data.get("position", [0, 0])
	return Vector2(float(pair[0]), float(pair[1])) if pair.size() == 2 else Vector2.ZERO


## Upgrades older save formats to SAVE_VERSION (only v1 exists so far).
func migrate(data: Dictionary) -> Dictionary:
	if int(data.get("version", 0)) < 1:
		data["version"] = 1
	return data
