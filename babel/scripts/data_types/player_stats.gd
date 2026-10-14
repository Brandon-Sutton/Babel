class_name PlayerStats
extends Resource
## Level, experience and attributes for the run (RPG-001/002, GDD §6.7). Owned by
## Game.stats. STR raises attack, CON raises defense and HP growth, INT raises MP growth,
## LCK raises critical hits.

signal leveled_up(new_level: int)
signal died

const MAX_LEVEL: int = 99

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
## Weapon in the attacking hand; adds its attack to STR.
@export var weapon: WeaponData


## Experience needed to go from [param from_level] to the next level.
static func xp_to_next(from_level: int) -> int:
	return roundi(20.0 * pow(from_level, 1.5))


## Total experience at which [param target_level] is reached.
static func xp_total_for(target_level: int) -> int:
	var total: int = 0
	for l: int in range(1, target_level):
		total += xp_to_next(l)
	return total


## Attack power of the equipped hand: STR plus the weapon's attack.
func attack_power() -> int:
	return strength + (weapon.attack if weapon != null else 0)


func defense() -> int:
	return floori(constitution / 2.0)


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
