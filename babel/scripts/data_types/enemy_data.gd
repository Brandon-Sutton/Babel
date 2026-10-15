class_name EnemyData
extends Resource
## Stats for one enemy type (AI-001). Instances live in res://data/enemies/ and are
## indexed by Db through [member id].

@export var id: StringName
@export var display_name: String
@export var max_hp: int = 20
## Power of contact damage and attacks; the player's defense is applied on top.
@export var attack: int = 8
@export var defense: int = 0
@export var xp: int = 5
@export var move_speed: float = 40.0
## Horizontal distance at which the enemy notices the player.
@export var aggro_range: float = 180.0
## Hits doing less damage than this don't stagger it (0 = always staggers).
@export var poise: int = 0
## Whether touching its body hurts the player.
@export var contact_damage: bool = true
## Rolled once when it dies (INV-013), with the player's luck. Usually a common and a
## rare piece of gear among Embers and shekels.
@export var loot: LootTable
