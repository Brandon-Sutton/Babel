class_name Shop
extends RefCounted
## Buying from a shop (NPC-004): prices, whether something can be bought, and what a
## purchase gives. Gear goes to the bag and can be bought again; a relic grants its
## ability at once and a Surveyor's Map adds its section to the map (MAP-005), and both
## are bought only once.


## The price of [param item_id] in [param shop], in shekels.
static func price(shop: ShopData, item_id: StringName) -> int:
	if shop != null and shop.prices.has(item_id):
		return shop.prices[item_id]
	var item: ItemData = Game.item(item_id)
	return item.price if item != null else 0


## &"ok", &"owned" (a relic or map Elam already has), &"poor" (not enough shekels) or
## &"unknown" (no such item).
static func status(shop: ShopData, item_id: StringName) -> StringName:
	var item: ItemData = Game.item(item_id)
	if item == null:
		return &"unknown"
	if owns(item):
		return &"owned"
	if Game.stats.shekels < price(shop, item_id):
		return &"poor"
	return &"ok"


## True for a relic or map Elam already has. Gear never counts as owned: it can be
## bought again.
static func owns(item: ItemData) -> bool:
	if item is RelicData:
		return Game.owns_relic(item as RelicData)
	if item is MapData:
		return Game.inventory.count(item.id) > 0
	return false


## Buys [param item_id] from [param shop]: takes the shekels and gives the item. Returns
## whether it was bought.
static func buy(shop: ShopData, item_id: StringName) -> bool:
	if status(shop, item_id) != &"ok":
		return false
	var item: ItemData = Game.item(item_id)
	Game.stats.add_shekels(-price(shop, item_id))
	if item is RelicData:
		Game.grant_ability((item as RelicData).ability)
	else:
		Game.inventory.add(item_id)
	Game.stats.emit_changed()
	Events.item_acquired.emit(item_id, 1)
	return true


## For a map: how many of its section's cells there are and how many are explored.
static func map_progress(map: MapData) -> Vector2i:
	var total: int = 0
	var explored: int = 0
	for cell: Vector2i in WorldMap.cells:
		var entry: Dictionary = WorldMap.cells[cell]
		if entry.get("secret", false) or not map.covers(cell, StringName(str(entry.get("region", "")))):
			continue
		total += 1
		if WorldMap.is_discovered(cell):
			explored += 1
	return Vector2i(total, explored)
