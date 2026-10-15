extends Node
## Run state for the current playthrough: player stats and equipment, inventory,
## persistent world flags, abilities, play time. SaveSystem serializes all of it.

## Starting kit (INV-012 will strip it at the Grand Gate later).
const STARTING_EQUIPMENT: Dictionary[StringName, StringName] = {
	&"right_hand": &"short_sword", &"body": &"masons_mail", &"mantle": &"crimson_mantle",
}
## Carried from the start for now so every item can be tried in the menu.
const STARTING_INVENTORY: Array[StringName] = [
	&"sappara", &"lapis_shield", &"scribes_circlet", &"seal_of_shamash", &"scythe_of_ninurta",
]

## Level, experience, attributes, HP/MP, currencies and equipped items.
var stats: PlayerStats
## Items carried but not equipped.
var inventory: Inventory
## One-time world state, keyed "<room_id>/<node_name>" or by story beat.
var flags: Dictionary[StringName, bool] = {}
## Abilities granted by relics, e.g. &"double_jump".
var abilities: Dictionary[StringName, bool] = {}
## Seconds played in this run (stops while the game is paused).
var play_time: float = 0.0


func _ready() -> void:
	reset()


func _process(delta: float) -> void:
	play_time += delta


## Sets a world flag and announces it on [code]Events.flag_set[/code].
func set_flag(flag: StringName, value: bool = true) -> void:
	flags[flag] = value
	Events.flag_set.emit(flag, value)


## Returns the flag's value; unknown flags are false.
func is_flag(flag: StringName) -> bool:
	return flags.get(flag, false)


## Returns true if the player owns [param ability].
func has_ability(ability: StringName) -> bool:
	return abilities.get(ability, false)


## Grants [param ability] to the player.
func grant_ability(ability: StringName) -> void:
	abilities[ability] = true


## The item with [param id], or null if no such item exists.
func item(id: StringName) -> ItemData:
	return Db.get_entry(id) as ItemData


## Puts the carried item [param item_id] in [param slot], returning whatever it takes off
## to the inventory (both hands' items when the two-handed rule applies). An empty
## [param item_id] just unequips the slot. Returns false if the item isn't carried or
## doesn't fit the slot.
func equip(slot: StringName, item_id: StringName) -> bool:
	var equipment: EquipmentData = null
	if not item_id.is_empty():
		equipment = item(item_id) as EquipmentData
		if equipment == null or inventory.count(item_id) == 0 or not PlayerStats.fits(equipment, slot):
			return false
	var removed: Array[EquipmentData] = stats.equip(slot, equipment)
	if equipment != null:
		inventory.remove(item_id)
	for previous: EquipmentData in removed:
		inventory.add(previous.id)
	return true


## Starts a fresh run: new stats with the starting kit, no flags or abilities.
func reset() -> void:
	stats = PlayerStats.new()
	inventory = Inventory.new()
	for slot: StringName in STARTING_EQUIPMENT:
		stats.equip(slot, item(STARTING_EQUIPMENT[slot]) as EquipmentData)
	for item_id: StringName in STARTING_INVENTORY:
		inventory.add(item_id)
	flags.clear()
	abilities.clear()
	play_time = 0.0
