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
## This weapon's own versions of Elam's animations (EQV-015), e.g.
## {&"attack": &"scythe_attack", &"idle": &"scythe_idle"}. Animations without an entry
## use the shared ones.
@export var animations: Dictionary[StringName, StringName] = {}


## Total frames of one swing.
func total_frames() -> int:
	return startup_frames + active_frames + recovery_frames
