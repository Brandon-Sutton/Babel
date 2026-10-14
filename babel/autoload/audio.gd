extends Node
## Music, ambience and sound effects. AUD-001 creates the buses; AUD-002 adds music
## (AudioStreamInteractive) and ambience; AUD-003 adds pooled SFX.

const BUS_MASTER: StringName = &"Master"
const BUS_MUSIC: StringName = &"Music"
const BUS_SFX: StringName = &"SFX"
const BUS_AMBIENCE: StringName = &"Ambience"
const BUS_VOICE: StringName = &"Voice"
const BUS_UI: StringName = &"UI"


## Sets [param bus] volume from a linear 0–1 value. Unknown buses log a warning.
func set_bus_volume(bus: StringName, linear: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus)
	if bus_index < 0:
		push_warning("Audio: unknown bus '%s'." % bus)
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(clampf(linear, 0.0, 1.0)))
