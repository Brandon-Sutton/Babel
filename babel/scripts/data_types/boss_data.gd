class_name BossData
extends EnemyData
## Stats and fight design of a boss (BOSS-000), on top of EnemyData. Instances live in
## res://data/enemies/ beside the other enemies.

## Shown under the name on the name card, e.g. "A saint the tower would not let die".
@export var title: String
## Health fractions where each new phase begins, highest first: [0.5] gives phase 1
## from half health down.
@export var phase_thresholds: PackedFloat32Array = [0.5]
## How much faster each phase after the first plays its patterns (wind-ups and rests are
## divided by this once per phase).
@export var phase_speed: float = 1.25
## Frames of rest between patterns, before the phase speed-up.
@export var rest_frames: int = 40
## What it can do.
@export var patterns: Array[BossPattern] = []
## Item, relic or map dropped on defeat, always.
@export var reward: StringName


## The phase for [param health_fraction] (1 = full health).
func phase_for(health_fraction: float) -> int:
	var phase: int = 0
	for threshold: float in phase_thresholds:
		if health_fraction <= threshold:
			phase += 1
	return phase


## Multiplier for the speed of patterns and rests in [param phase].
func speed_for(phase: int) -> float:
	return pow(phase_speed, phase)
