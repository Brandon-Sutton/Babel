class_name Combat
## Damage rules shared by the player and enemies (CBT-003). Elements, resistances and
## status effects arrive with CBT-003/007; this covers attack, defense and critical hits.

const CRIT_MULTIPLIER: float = 1.5
## Critical chance per point of luck, and its cap.
const CRIT_PER_LUCK: float = 0.005
const CRIT_CAP: float = 0.25


## Damage of an attack with power [param attack] against [param defense]: attack minus
## half the defense (times CRIT_MULTIPLIER on a critical), never below 1.
static func damage(attack: int, defense: int, critical: bool = false) -> int:
	var base: float = float(attack) - defense / 2.0
	if critical:
		base *= CRIT_MULTIPLIER
	return maxi(1, roundi(base))


## Chance of a critical hit for [param luck], from 0 to CRIT_CAP.
static func crit_chance(luck: int) -> float:
	return clampf(luck * CRIT_PER_LUCK, 0.0, CRIT_CAP)
