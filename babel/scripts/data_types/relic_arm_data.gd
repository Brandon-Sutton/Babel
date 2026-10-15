class_name RelicArmData
extends ItemData
## SUB-001: a Relic Arm (sub-weapon), thrown with the relic_arm button or Up + Attack and
## paid in Embers (GDD §6.5). One is carried at a time; picking up another swaps it.

## Embers spent per throw.
@export var cost: int = 1
## Damage of a hit.
@export var damage: int = 12
## &"straight" flies level; &"arc" is thrown up and falls.
@export var flight: StringName = &"straight"
@export var speed: float = 320.0
## Upward launch speed for arcs, in px/s.
@export var lift: float = 0.0
@export var gravity: float = 0.0
## Keeps going through enemies instead of breaking on the first hit.
@export var pierce: bool = false
## How many can be in flight at once.
@export var max_on_screen: int = 2
## Hitbox size in px.
@export var size: Vector2 = Vector2(8, 8)
@export var color: Color = Color("c8b8a0")
## Short label for the HUD.
@export var short_name: String = "ARM"
