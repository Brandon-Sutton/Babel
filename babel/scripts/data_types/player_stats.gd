class_name PlayerStats
extends Resource
## Level, experience, attributes, equipment and currencies for the run (RPG-001/002,
## INV-004, GDD §6.7). Owned by Game.stats. STR raises attack, CON raises defense and HP
## growth, INT raises MP growth, LCK raises critical hits and item drops. Equipment adds
## its attack, defense and attribute bonuses on top of the base values.

signal leveled_up(new_level: int)
signal died

const MAX_LEVEL: int = 99

## Equipment slots in menu order, and which item kinds each accepts.
const SLOTS: Array[StringName] = [&"right_hand", &"left_hand", &"head", &"body", &"mantle", &"seal_1", &"seal_2"]
const SLOT_LABELS: Dictionary[StringName, String] = {
	&"right_hand": "R.HAND", &"left_hand": "L.HAND", &"head": "HEAD", &"body": "BODY",
	&"mantle": "MANTLE", &"seal_1": "SEAL", &"seal_2": "SEAL",
}
const SLOT_KINDS: Dictionary[StringName, EquipmentData.Kind] = {
	&"right_hand": EquipmentData.Kind.WEAPON, &"left_hand": EquipmentData.Kind.SHIELD,
	&"head": EquipmentData.Kind.HEAD, &"body": EquipmentData.Kind.BODY,
	&"mantle": EquipmentData.Kind.MANTLE, &"seal_1": EquipmentData.Kind.SEAL,
	&"seal_2": EquipmentData.Kind.SEAL,
}

@export var level: int = 1
## Total experience earned this run.
@export var xp: int = 0
@export var strength: int = 6
@export var constitution: int = 6
@export var intelligence: int = 6
@export var luck: int = 6
@export var max_hp: int = 80
@export var max_mp: int = 20
@export var hp: int = 80
@export var mp: int = 20
## Relic Arm ammunition (Symphony of the Night's hearts), dropped by votive lamps.
@export var embers: int = 10
@export var max_embers: int = 50
## Money.
@export var shekels: int = 0

## What is worn in each slot (missing key = empty).
var equipped: Dictionary[StringName, EquipmentData] = {}
## The Relic Arm carried (SUB-001), or null.
var relic_arm: RelicArmData

## The right-hand weapon (shorthand for equipped[&"right_hand"]).
var weapon: WeaponData:
	get:
		return equipped.get(&"right_hand") as WeaponData
	set(value):
		if value == null:
			equipped.erase(&"right_hand")
		else:
			equipped[&"right_hand"] = value


## Experience needed to go from [param from_level] to the next level.
static func xp_to_next(from_level: int) -> int:
	return roundi(20.0 * pow(from_level, 1.5))


## Total experience at which [param target_level] is reached.
static func xp_total_for(target_level: int) -> int:
	var total: int = 0
	for l: int in range(1, target_level):
		total += xp_to_next(l)
	return total


## True if [param item] may go in [param slot].
static func fits(item: EquipmentData, slot: StringName) -> bool:
	return item != null and SLOT_KINDS.has(slot) and item.kind == SLOT_KINDS[slot]


## Attribute including equipment bonuses: &"strength", &"constitution", &"intelligence"
## or &"luck".
func total(attribute: StringName) -> int:
	var value: int = int(get(attribute))
	for item: EquipmentData in equipped.values():
		value += int(item.get(attribute))
	return value


## Attack power of the right hand: total STR plus the weapon's attack.
func attack_power() -> int:
	var weapon_attack: int = weapon.attack if weapon != null else 0
	return total(&"strength") + weapon_attack


## Defense: half the total CON plus every equipped item's defense.
func defense() -> int:
	var armor: int = 0
	for item: EquipmentData in equipped.values():
		armor += item.defense
	return floori(total(&"constitution") / 2.0) + armor


## Puts [param item] in [param slot] (null empties it) and returns everything taken off:
## the slot's previous item, plus the other hand's item when the two-handed rule applies
## (INV-015): a two-handed weapon empties the left hand, and putting anything in the left
## hand takes a two-handed weapon off. Items that don't fit the slot are refused, and
## nothing changes.
func equip(slot: StringName, item: EquipmentData) -> Array[EquipmentData]:
	if item != null and not fits(item, slot):
		return []
	var removed: Array[EquipmentData] = _apply(slot, item)
	emit_changed()
	return removed


## Total of passive [param key] over everything equipped (INV-016), e.g. &"mp_regen".
func passive(key: StringName) -> float:
	var total_value: float = 0.0
	for item: EquipmentData in equipped.values():
		total_value += item.passives.get(key, 0.0)
	return total_value


## True if an equipped item grants [param ability] (INV-016).
func equipment_grants(ability: StringName) -> bool:
	for item: EquipmentData in equipped.values():
		if ability in item.abilities:
			return true
	return false


## Spends [param amount] Embers if there are enough; returns whether it did.
func spend_embers(amount: int) -> bool:
	if embers < amount:
		return false
	embers -= amount
	emit_changed()
	return true


## True if [param item] is a weapon held in both hands.
static func is_two_handed(item: EquipmentData) -> bool:
	return item is WeaponData and (item as WeaponData).two_handed


## True while a two-handed weapon is held, so the left hand is taken.
func hands_full() -> bool:
	return is_two_handed(equipped.get(&"right_hand"))


func _apply(slot: StringName, item: EquipmentData) -> Array[EquipmentData]:
	var removed: Array[EquipmentData] = []
	if equipped.has(slot):
		removed.append(equipped[slot])
	if item == null:
		equipped.erase(slot)
		return removed
	equipped[slot] = item
	var other: StringName = &""
	if slot == &"right_hand" and is_two_handed(item):
		other = &"left_hand"
	elif slot == &"left_hand" and hands_full():
		other = &"right_hand"
	if not other.is_empty() and equipped.has(other):
		removed.append(equipped[other])
		equipped.erase(other)
	return removed


## Attack, defense and the four attributes as they would be with [param item] in
## [param slot] (two-handed rule included), without changing anything (for the equip
## menu's comparison).
func preview(slot: StringName, item: EquipmentData) -> Dictionary[StringName, int]:
	var saved: Dictionary[StringName, EquipmentData] = equipped.duplicate()
	_apply(slot, item)
	var result: Dictionary[StringName, int] = summary()
	equipped = saved
	return result


## Current attack, defense and attributes (totals including equipment).
func summary() -> Dictionary[StringName, int]:
	return {
		&"attack": attack_power(), &"defense": defense(), &"strength": total(&"strength"),
		&"constitution": total(&"constitution"), &"intelligence": total(&"intelligence"),
		&"luck": total(&"luck"),
	}


## Experience still needed for the next level (0 at the level cap).
func xp_to_next_level() -> int:
	return 0 if level >= MAX_LEVEL else xp_total_for(level + 1) - xp


func is_dead() -> bool:
	return hp <= 0


## Adds experience and applies every level-up it earns.
func add_xp(amount: int) -> void:
	xp += maxi(0, amount)
	while level < MAX_LEVEL and xp >= xp_total_for(level + 1):
		_level_up()
	emit_changed()


## Lowers HP (never below 0) and returns the HP left. Emits died on reaching 0.
func take_damage(amount: int) -> int:
	if hp <= 0:
		return 0
	hp = maxi(0, hp - maxi(0, amount))
	emit_changed()
	if hp == 0:
		died.emit()
	return hp


func heal(amount: int) -> void:
	hp = mini(max_hp, hp + maxi(0, amount))
	emit_changed()


func spend_mp(amount: int) -> bool:
	if mp < amount:
		return false
	mp -= amount
	emit_changed()
	return true


## Restores Breath (MP), up to the maximum.
func restore_mp(amount: int) -> void:
	mp = mini(max_mp, mp + maxi(0, amount))
	emit_changed()


func add_embers(amount: int) -> void:
	embers = clampi(embers + amount, 0, max_embers)
	emit_changed()


func add_shekels(amount: int) -> void:
	shekels = maxi(0, shekels + amount)
	emit_changed()


## Refills HP and MP (save rooms, respawn).
func full_restore() -> void:
	hp = max_hp
	mp = max_mp
	emit_changed()


func _level_up() -> void:
	level += 1
	strength += 1
	constitution += 1
	intelligence += 1
	luck += 1
	var hp_gain: int = 8 + floori(constitution / 4.0)
	var mp_gain: int = 3 + floori(intelligence / 8.0)
	max_hp += hp_gain
	hp += hp_gain
	max_mp += mp_gain
	mp += mp_gain
	leveled_up.emit(level)
