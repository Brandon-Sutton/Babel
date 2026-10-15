@abstract
class_name ItemData
extends Resource
## Base of everything the player can own (INV-001). Instances live in res://data/ and
## are looked up by [member id] through Db.

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
## Shop price in shekels (0 = can't be sold).
@export var price: int = 0
