extends Node
## Loads rooms into the World node and runs transitions. WLD-002 implements room changes
## with fades and player placement; WLD-003 adds threaded preloading of neighbours.

## The World node rooms are added under. Set by the main scene on startup.
var world: Node2D


## Called by the main scene so rooms have somewhere to live.
func register_world(node: Node2D) -> void:
	world = node
