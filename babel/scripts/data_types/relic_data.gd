class_name RelicData
extends ItemData
## A relic (GDD §6.2): grants an ability while owned, and is worn visibly on Elam
## (EQV-010). Menu toggling comes with REL-001.

## Ability granted while the relic is owned, e.g. &"double_jump".
@export var ability: StringName
@export var worn: WornArt
