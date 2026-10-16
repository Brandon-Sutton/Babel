class_name ShopData
extends Resource
## A shop's stock (NPC-004): who keeps it and what they sell, in the order shown. Prices
## come from each item's [member ItemData.price] unless [member prices] overrides one.

@export var id: StringName
## Shown at the top of the shop.
@export var keeper: String
## The keeper's line when the shop opens.
@export var greeting: String
## Item ids for sale, in display order.
@export var stock: Array[StringName] = []
## Price overrides by item id.
@export var prices: Dictionary[StringName, int] = {}
