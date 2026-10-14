class_name HealthComponent
extends Node
## Hit points for enemies and breakables (CBT-002). The player's HP lives in
## PlayerStats instead, because it persists across rooms and levels.

signal damaged(amount: int, info: DamageInfo)
signal healed(amount: int)
signal died

@export var max_health: int = 10
var health: int = 10
## Frames left during which damage is ignored.
var invulnerable_frames_left: int = 0


func _ready() -> void:
	health = max_health


func _physics_process(_delta: float) -> void:
	tick()


## Advances the invulnerability countdown by one frame (called every physics frame).
func tick() -> void:
	if invulnerable_frames_left > 0:
		invulnerable_frames_left -= 1


func is_alive() -> bool:
	return health > 0


## Sets both maximum and current health (spawning from EnemyData).
func reset(new_max: int) -> void:
	max_health = maxi(1, new_max)
	health = max_health
	invulnerable_frames_left = 0


## Applies damage unless dead or invulnerable; then ignores further damage for
## [param invulnerable_frames]. Returns whether the damage was applied.
func apply_damage(amount: int, info: DamageInfo = null, invulnerable_frames: int = 0) -> bool:
	if not is_alive() or invulnerable_frames_left > 0:
		return false
	health = maxi(0, health - maxi(0, amount))
	invulnerable_frames_left = invulnerable_frames
	damaged.emit(amount, info)
	if health == 0:
		died.emit()
	return true


func heal(amount: int) -> void:
	if not is_alive():
		return
	var before: int = health
	health = mini(max_health, health + maxi(0, amount))
	if health > before:
		healed.emit(health - before)
