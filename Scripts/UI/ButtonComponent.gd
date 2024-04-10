extends RefCounted
class_name ButtonComponent

@export var toggleOnPress: bool = false
@export var toggleStates: int = 1

class ButtonState:
	var isHovered: bool
	var isPressed: bool
	var isDisabled: bool
	var toggleState: int
	func _init(isHovered_: bool, isPressed_: bool, isDisabled_: bool, toggleState_: int):
		isHovered = isHovered_
		isPressed = isPressed_
		isDisabled = isDisabled_
		toggleState = toggleState_
	func duplicate() -> ButtonState:
		return ButtonState.new(isHovered, isPressed, isDisabled, toggleState)

var state: ButtonState = ButtonState.new(false, false, false, 0)

signal stateUpdated(oldState: ButtonState, newState: ButtonState)

func updateState(oldState: ButtonState, newState: ButtonState):
	state = newState
	stateUpdated.emit(oldState, newState)

func hover():
	var newState: ButtonState = state.duplicate()
	newState.isHovered = true
	updateState(state, newState)

func unhover():
	var newState: ButtonState = state.duplicate()
	newState.isHovered = false
	updateState(state, newState)

func press():
	var newState: ButtonState = state.duplicate()
	newState.isPressed = true
	if toggleOnPress: newState.toggleState = (newState.toggleState + 1) % toggleStates
	updateState(state, newState)

func unpress():
	var newState: ButtonState = state.duplicate()
	newState.isPressed = false
	if !toggleOnPress: newState.toggleState = (newState.toggleState + 1) % toggleStates
	updateState(state, newState)

func enable():
	var newState: ButtonState = state.duplicate()
	newState.isDisabled = false
	updateState(state, newState)

func disable():
	var newState: ButtonState = state.duplicate()
	newState.isDisabled = true
	updateState(state, newState)
