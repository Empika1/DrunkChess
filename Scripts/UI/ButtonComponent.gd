extends RefCounted
class_name ButtonComponent

@export var toggleOnPress: bool = false
@export var toggleStates: int = 1

class ButtonState:
	var isHoveredIgnoreDisable: bool
	var isPressedIgnoreDisable: bool
	
	var isHovered: bool
	var isPressed: bool
	var isDisabled: bool
	var toggleState: int
	func _init(isHoveredIgnoreDisable_: bool, isPressedIgnoreDisable_: bool,
		isHovered_: bool, isPressed_: bool, isDisabled_: bool, toggleState_: int):
		isHoveredIgnoreDisable = isHoveredIgnoreDisable_
		isPressedIgnoreDisable = isPressedIgnoreDisable_
		isHovered = isHovered_
		isPressed = isPressed_
		isDisabled = isDisabled_
		toggleState = toggleState_
	func duplicate() -> ButtonState:
		return ButtonState.new(isHoveredIgnoreDisable, isPressedIgnoreDisable, 
			isHovered, isPressed, isDisabled, toggleState)

var state: ButtonState = ButtonState.new(false, false, false, false, false, 0)

static func justHovered(oldState: ButtonState, newState: ButtonState):
	return newState.isHovered and !oldState.isHovered and newState.isDisabled == oldState.isDisabled

static func justUnhovered(oldState: ButtonState, newState: ButtonState):
	return !newState.isPressed and oldState.isPressed and !newState.isDisabled

static func justPressed(oldState: ButtonState, newState: ButtonState):
	return newState.isPressed and !oldState.isPressed and newState.isDisabled == oldState.isDisabled

static func justReleased(oldState: ButtonState, newState: ButtonState):
	return !newState.isPressed and oldState.isPressed and !newState.isDisabled

static func justToggled(oldState: ButtonState, newState: ButtonState):
	return oldState.toggleState != newState.toggleState

signal stateUpdated(oldState: ButtonState, newState: ButtonState)

func updateState(oldState: ButtonState, newState: ButtonState):
	state = newState
	stateUpdated.emit(oldState, newState)

func hover():
	var newState: ButtonState = state.duplicate()
	newState.isHoveredIgnoreDisable = true
	if !newState.isDisabled:
		newState.isHovered = true
	updateState(state, newState)

func unhover():
	var newState: ButtonState = state.duplicate()
	newState.isHoveredIgnoreDisable = false
	if !newState.isDisabled:
		newState.isHovered = false
	updateState(state, newState)

func press():
	var newState: ButtonState = state.duplicate()
	newState.isPressedIgnoreDisable = true
	if !newState.isDisabled:
		newState.isPressed = true
		if toggleOnPress: newState.toggleState = (newState.toggleState + 1) % toggleStates
	updateState(state, newState)

func unpress():
	var newState: ButtonState = state.duplicate()
	newState.isPressedIgnoreDisable = false
	if !newState.isDisabled:
		newState.isPressed = false
		if !toggleOnPress: newState.toggleState = (newState.toggleState + 1) % toggleStates
	updateState(state, newState)

func enable():
	var newState: ButtonState = state.duplicate()
	newState.isDisabled = false
	newState.isPressed = newState.isPressedIgnoreDisable
	newState.isHovered = newState.isHoveredIgnoreDisable
	updateState(state, newState)

func disable():
	var newState: ButtonState = state.duplicate()
	newState.isDisabled = true
	newState.isHovered = false
	newState.isPressed = false
	updateState(state, newState)
