extends ColorRect

@export var idleCol: Color
@export var hoveredCol: Color
@export var pressedCol: Color
@export var disabledCol: Color

var buttonComponent: ButtonComponent  = ButtonComponent.new()

func _ready():
	buttonComponent.stateUpdated.connect(updateState)
	
	mouse_entered.connect(buttonComponent.hover)
	mouse_exited.connect(buttonComponent.unhover)

func _input(event):	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and buttonComponent.state.isHovered:
			buttonComponent.press()
		elif !event.is_pressed():
			buttonComponent.unpress()

func updateState(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if newState.isDisabled:
		color = disabledCol
	elif newState.isPressed:
		color = pressedCol
	elif newState.isHovered:
		color = hoveredCol
	else:
		color = idleCol
