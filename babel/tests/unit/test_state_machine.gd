extends GutTest
## PLR-002: transitions, enter/exit order, update routing, unknown-state rejection.


class RecordingState extends State:
	var log: Array[String]

	func enter(previous: StringName) -> void:
		log.append("enter %s from %s" % [name, previous])

	func exit() -> void:
		log.append("exit %s" % name)

	func physics_update(_delta: float) -> void:
		log.append("update %s" % name)


var machine: StateMachine
var log: Array[String] = []


func before_each() -> void:
	log = []
	machine = StateMachine.new()
	for state_name: String in ["Idle", "Run"]:
		var state: RecordingState = RecordingState.new()
		state.name = state_name
		state.log = log
		machine.add_child(state)
	add_child_autofree(machine)


func test_transitions_call_exit_then_enter() -> void:
	machine.transition_to(&"Idle")
	machine.transition_to(&"Run")
	assert_eq(log, ["enter Idle from ", "exit Idle", "enter Run from Idle"] as Array[String])
	assert_eq(machine.current_name(), &"Run")


func test_physics_update_goes_to_current_state() -> void:
	machine.transition_to(&"Run")
	machine.physics_update(0.016)
	assert_eq(log.back(), "update Run")


func test_unknown_state_is_rejected() -> void:
	machine.transition_to(&"Idle")
	machine.transition_to(&"Nope")
	assert_eq(machine.current_name(), &"Idle")
	assert_push_error("unknown state")


func test_emits_state_changed() -> void:
	watch_signals(machine)
	machine.transition_to(&"Idle")
	assert_signal_emitted_with_parameters(machine, "state_changed", [&"", &"Idle"])
