class_name WeaponData
extends Resource
## A melee weapon: power, swing timing and hitbox (PLR-007). Timings are frames at
## 60 Hz: startup (wind-up), active (hitbox on), recovery (can't act). INV-001 later
## folds this into the ItemData hierarchy.

@export var id: StringName
@export var display_name: String
@export var attack: int = 5
@export var startup_frames: int = 4
@export var active_frames: int = 6
@export var recovery_frames: int = 10
## Hitbox width in front of the body, in pixels.
@export var reach: float = 46.0
@export var hitbox_height: float = 30.0
## Horizontal knockback applied to what it hits, in px/s.
@export var knockback: float = 140.0
@export var hit_stop_frames: int = 4
## Colour of the placeholder slash arc until weapon sprites exist.
@export var slash_color: Color = Color("e8dfc4")


## Total frames of one swing.
func total_frames() -> int:
	return startup_frames + active_frames + recovery_frames
