class_name Hurtbox
extends Area2D
## Receives hits from Hitboxes (CBT-001). The owning actor decides what a hit does by
## setting [member handler] to a Callable(info: DamageInfo) -> bool that returns whether
## the hit counted (false while invulnerable or dead).

## Emitted for every accepted hit.
signal hit_received(info: DamageInfo)

## Callable(info: DamageInfo) -> bool. Without one, every hit is accepted.
var handler: Callable
## The actor this hurtbox belongs to (so its own hitboxes skip it).
var owner_node: Node


func _ready() -> void:
	monitorable = true
	if owner_node == null:
		owner_node = get_parent()


## Delivers [param info]; returns whether the owner accepted the hit.
func receive_hit(info: DamageInfo) -> bool:
	var accepted: bool = true
	if handler.is_valid():
		accepted = handler.call(info)
	if accepted:
		hit_received.emit(info)
	return accepted
