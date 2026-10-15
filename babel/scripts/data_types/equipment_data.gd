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


## Short label for the kind, for menus.
func kind_label() -> String:
	return ["WEAPON", "SHIELD", "HEAD", "BODY", "MANTLE", "SEAL"][kind]
