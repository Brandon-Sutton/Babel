class_name SpellData
extends Resource
## SPL-002 / SPL-020: a special move entered as a command plus Attack, paid in Breath.
## Utterances are learned (Game.spells); weapon arts belong to a weapon type
## (WeaponData.art) and work while that weapon is held. [member effect] picks the
## behaviour in SpecialMoves; the other fields tune it.

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
## Directions before the attack press, e.g. "D,DF,F" (see CommandInput).
@export var command: String = "D,DF,F"
## Frames allowed from the first direction to the attack press.
@export var window_frames: int = 24
## Breath (MP) spent.
@export var cost_mp: int = 5
## Wind-up before the effect starts, and recovery after it ends (frames at 60 Hz).
@export var cast_frames: int = 14
@export var recovery_frames: int = 14
## &"bolts", &"lunge", &"shockwave", &"whirl" or &"cleave".
@export var effect: StringName = &"bolts"
## Damage of its hits: for Utterances added to INT, for weapon arts to the weapon's ATK.
@export var power: int = 8
## Bolts or shockwaves spawned.
@export var count: int = 1
## Projectile speed in px/s.
@export var speed: float = 240.0
## Lunge distance, whirl radius or cleave reach, in px.
@export var distance: float = 64.0
## Frames the effect's hitbox stays out.
@export var active_frames: int = 10
@export var knockback: float = 200.0
@export var color: Color = Color("fbe69b")
