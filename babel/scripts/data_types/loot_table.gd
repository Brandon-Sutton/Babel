class_name LootTable
extends Resource
## Weighted drops for lamps and enemies (INV-007). Entry i is drops[i] with weights[i]
## and amounts[i]. A drop is "embers", "shekels", "nothing" or "item:<item id>".
## Luck makes item drops likelier (2% more weight per point).

@export var drops: PackedStringArray = []
@export var weights: PackedInt32Array = []
@export var amounts: PackedInt32Array = []


## One rolled drop.
class Drop:
	## &"embers", &"shekels", &"item" or &"nothing".
	var kind: StringName = &"nothing"
	var item_id: StringName = &""
	var amount: int = 0


## Picks one entry by weight using [param rng]. [param item_factor] multiplies the item
## entries' weights on top of luck (the Wanderer's Cube doubles them for lamps).
func roll(rng: RandomNumberGenerator, luck: int = 0, item_factor: float = 1.0) -> Drop:
	var total: float = 0.0
	var scaled: PackedFloat32Array = []
	for i: int in drops.size():
		var weight: float = float(weights[i]) if i < weights.size() else 1.0
		if drops[i].begins_with("item:"):
			weight *= (1.0 + luck * 0.02) * item_factor
		scaled.append(weight)
		total += weight
	var drop: Drop = Drop.new()
	if total <= 0.0:
		return drop
	var pick: float = rng.randf() * total
	for i: int in drops.size():
		pick -= scaled[i]
		if pick < 0.0:
			var entry: String = drops[i]
			drop.amount = amounts[i] if i < amounts.size() else 1
			if entry.begins_with("item:"):
				drop.kind = &"item"
				drop.item_id = StringName(entry.trim_prefix("item:"))
			else:
				drop.kind = StringName(entry)
			return drop
	return drop
