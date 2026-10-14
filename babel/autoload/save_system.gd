extends Node
## Versioned JSON save files in [code]user://saves/[/code]. Saves are never Godot
## Resources: loading a .tres/.res from user:// can execute embedded scripts.
## SAV-001 implements writing, reading and migration; this fixes location and version.

const SAVE_VERSION: int = 1
const SAVE_DIR: String = "user://saves"
const SLOT_COUNT: int = 3


## Returns the file path for save [param slot] (0-based).
func slot_path(slot: int) -> String:
	return SAVE_DIR.path_join("slot_%d.json" % slot)


## Returns true if save [param slot] exists on disk.
func has_save(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))
