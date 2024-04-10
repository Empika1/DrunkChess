extends CustomButton

@export var idleCol: Color
@export var hoveredCol: Color
@export var pressedCol: Color
@export var disabledCol: Color

func updateVisualState(oldState: ButtonState, newState: ButtonState):
	if newState.isDisabled:
		self.color = disabledCol
	elif newState.isPressed:
		self.color = pressedCol
	elif newState.isHovered:
		self.color = hoveredCol
	else:
		self.color = idleCol
