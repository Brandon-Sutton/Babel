extends GutTest
## ENG-005: every action in the CLAUDE.md input table exists with both a keyboard and a
## gamepad binding.

const ACTIONS: PackedStringArray = [
	"move_left", "move_right", "move_up", "move_down", "jump", "attack_right",
	"attack_left", "backdash", "relic_arm", "form_dust", "form_raven", "form_lion",
	"map", "pause",
]


func test_actions_have_keyboard_and_gamepad_bindings() -> void:
	for action: String in ACTIONS:
		assert_true(InputMap.has_action(action), "action %s missing" % action)
		if not InputMap.has_action(action):
			continue
		var has_key: bool = false
		var has_pad: bool = false
		for event: InputEvent in InputMap.action_get_events(action):
			if event is InputEventKey:
				has_key = true
			elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
				has_pad = true
		assert_true(has_key, "%s needs a keyboard binding" % action)
		assert_true(has_pad, "%s needs a gamepad binding" % action)
