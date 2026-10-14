class_name StateMachine
extends Node
## Finite state machine for the player, enemies and bosses (PLR-002). Its State children
## are keyed by node name; the owner calls [method physics_update] from _physics_process
## so state logic runs in a known order relative to movement.

## Emitted after every transition.
signal state_changed(from: StringName, to: StringName)

## State entered when the machine becomes ready.
@export var initial_state: StringName

## The active state (null until the first transition).
var current: State
var _states: Dictionary[StringName, State] = {}


func _ready() -> void:
	for child: Node in get_children():
		if child is State:
			register(child as State)
	if not initial_state.is_empty():
		transition_to(initial_state)


## Adds [param state] under its node name. Called automatically for State children.
func register(state: State) -> void:
	state.machine = self
	_states[StringName(state.name)] = state


## Exits the current state and enters [param state_name]. Unknown names are rejected
## with an error and the current state is kept.
func transition_to(state_name: StringName) -> void:
	if not _states.has(state_name):
		push_error("StateMachine: unknown state '%s'" % state_name)
		return
	var previous: StringName = current_name()
	if current != null:
		current.exit()
	current = _states[state_name]
	current.enter(previous)
	state_changed.emit(previous, state_name)


## Runs the current state's frame logic.
func physics_update(delta: float) -> void:
	if current != null:
		current.physics_update(delta)


## Name of the current state, or an empty StringName before the first transition.
func current_name() -> StringName:
	return StringName(current.name) if current != null else &""


## Returns true if a state called [param state_name] is registered.
func has_state(state_name: StringName) -> bool:
	return _states.has(state_name)
