@abstract
class_name State
extends Node
## One state of a StateMachine (PLR-002). The machine calls [method enter] and
## [method exit] on transitions and [method physics_update] every physics frame.

## The machine that owns this state; set by StateMachine before the first transition.
var machine: StateMachine


## Called when the machine switches to this state. [param previous] is the state it left
## (empty on the first transition).
func enter(_previous: StringName) -> void:
	pass


## Called when the machine leaves this state.
func exit() -> void:
	pass


## Called by the machine every physics frame while this state is current.
@abstract func physics_update(delta: float) -> void
