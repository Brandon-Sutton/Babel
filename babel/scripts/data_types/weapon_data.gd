class_name WeaponData
extends EquipmentData
## A melee weapon: power (EquipmentData.attack), swing timing and hitbox (PLR-007).
## Timings are frames at 60 Hz: startup (wind-up), active (hitbox on), recovery.

@export var startup_frames: int = 4
@export var active_frames: int = 6
@export var recovery_frames: int = 10
## Hitbox width in front of the body, in pixels.
@export var reach: float = 46.0
@export var hitbox_height: float = 30.0
## Horizontal knockback applied to what it hits, in px/s.
@export var knockback: float = 140.0
@export var hit_stop_frames: int = 4
## Colour of the swing smear (and of the placeholder arc where an animation has none).
@export var slash_color: Color = Color("e8dfc4")
## Held in both hands: the left hand must stay empty (INV-015).
@export var two_handed: bool = false
## The animation set Elam fights with while holding this weapon (EQV-016): he plays
## "<stance>_<move>" (e.g. two_handed_jump) wherever the sheet has it. Empty means
## &"two_handed" for two-handed weapons and the shared one-handed set otherwise.
@export var stance: StringName
## Single moves this weapon replaces on top of its stance (EQV-015), e.g.
## {&"attack": &"greatsword_attack"}.
@export var animations: Dictionary[StringName, StringName] = {}


## Animations to try for Elam's [param move], best first; the shared [param move] is the
## fallback after these.
func animation_candidates(move: StringName) -> Array[StringName]:
	var candidates: Array[StringName] = []
	if animations.has(move):
		candidates.append(animations[move])
	var set_name: StringName = stance if not stance.is_empty() else (&"two_handed" if two_handed else &"")
	if not set_name.is_empty():
		candidates.append(StringName("%s_%s" % [set_name, move]))
	return candidates


## Total frames of one swing.
func total_frames() -> int:
	return startup_frames + active_frames + recovery_frames
