class_name MapData
extends ItemData
## A Surveyor's Map (MAP-005), sold by Archivist Nabu. Owning one adds a section of the
## tower to the Builder's Plan: the section's unvisited rooms show dim on the map, its
## explored rooms stay highlighted, and secret rooms stay hidden. The section is every
## map cell of [member region] inside [member area]; leaving either empty means "any".

## Region code (GDD §5.2) of the rooms it shows; empty for any region.
@export var region: StringName
## Map cells it shows (one cell is one screen); empty for the whole region.
@export var area: Rect2i


## True if this map shows [param cell], a cell of a room in [param cell_region].
func covers(cell: Vector2i, cell_region: StringName) -> bool:
	if not region.is_empty() and region != cell_region:
		return false
	return not area.has_area() or area.has_point(cell)
