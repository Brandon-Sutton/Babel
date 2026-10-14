class_name DamageInfo
extends RefCounted
## One hit, passed from a Hitbox to a Hurtbox (CBT-001). The receiver applies its own
## defense with Combat.damage().

## Attack power of the source.
var attack: int = 0
var critical: bool = false
## Horizontal knockback speed in px/s.
var knockback: float = 0.0
## Direction the target is pushed: -1 left, 1 right.
var direction: float = 1.0
var hit_stop_frames: int = 0
## Where the hit happened (for sparks and damage numbers).
var position: Vector2 = Vector2.ZERO
var source: Node
