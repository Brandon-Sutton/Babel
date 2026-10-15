class_name WornArt
extends Resource
## EQV-004: how an item looks on Elam (GDD §6.7, visible equipment). The sprite is
## placed on one or more of the body's attach points every frame by EquipmentRig.
## Hand items are drawn pointing right (0°) with the grip on [member pivot], and turn
## with the hand when [member follows_angle] is set.

enum Layer { BEHIND, FRONT }

@export var texture: Texture2D
## Pixel of [member texture] that sits on the attach point (a weapon's grip, a seal's cord).
@export var pivot: Vector2 = Vector2.ZERO
## Attach points it is drawn at: hand_r, hand_l, head, neck, chest, belt, ankle_f,
## ankle_b, or &"seal" for the point that belongs to the seal slot it is worn in.
@export var points: Array[StringName] = [&"hand_r"]
@export var layer: Layer = Layer.FRONT
## Turn with the hand's angle (weapons). Otherwise the sprite stays upright.
@export var follows_angle: bool = false
## Degrees added to the hand angle.
@export var angle_offset: float = 0.0
