class_name EquipmentData
extends ItemData
## Anything worn or held (INV-004): weapons, shields, helms, armor, mantles and seals.
## Bonuses add to the player's attributes while equipped.

## Which equipment slots accept this item.
enum Kind { WEAPON, SHIELD, HEAD, BODY, MANTLE, SEAL }

@export var kind: Kind = Kind.WEAPON
@export var attack: int = 0
@export var defense: int = 0
@export var strength: int = 0
@export var constitution: int = 0
@export var intelligence: int = 0
@export var luck: int = 0

@export_group("Abilities and passives")
## Abilities granted while the item is worn, e.g. &"double_jump" (INV-016).
@export var abilities: Array[StringName] = []
## Passive effects while worn, summed over all equipped items (PlayerStats.passive):
## &"mp_regen" and &"hp_regen" (points per second), &"lifesteal" (share of melee damage
## healed), &"ember_saver" (chance a Relic Arm costs nothing), &"run_speed" (fraction
## added to run speed).
@export var passives: Dictionary[StringName, float] = {}

@export_group("Visible on Elam")
## Rigid sprite worn or held (weapons, shields, helms, seals, add-on armor pieces).
@export var worn: WornArt
## Material recolored while equipped: &"plates" (body armor) or &"lining" (mantles).
@export var dye_material: StringName
## Replacement ramp for [member dye_material], dark to light.
@export var dye_ramp: PackedColorArray = []


## Short label for the kind, for menus.
func kind_label() -> String:
	return ["WEAPON", "SHIELD", "HEAD", "BODY", "MANTLE", "SEAL"][kind]
