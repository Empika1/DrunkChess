extends Control
class_name ModulateScaleButton

@export var useDefaultScale: bool
@export var scaleDefault: float
@export var scaleHovered: float
@export var scalePressed: float
@export var scaleDisabled: float
@export var useNonToggledScale: bool
@export var scaleDefaultToggled: float
@export var scaleHoveredToggled: float
@export var scalePressedToggled: float
@export var scaleDisabledToggled: float

@export var useDefaultModulate: bool
@export var modulateDefault: Color
@export var modulateHovered: Color
@export var modulatePressed: Color
@export var modulateDisabled: Color
@export var useNonToggledModulate: bool
@export var modulateDefaultToggled: Color
@export var modulateHoveredToggled: Color
@export var modulatePressedToggled: Color
@export var modulateDisabledToggled: Color

@export var useDefaultSprite: bool
@export var spriteDefault: Control
@export var spriteHovered: Control
@export var spritePressed: Control
@export var spriteDisabled: Control
@export var useNonToggledSprite: bool
@export var spriteDefaultToggled: Control
@export var spriteHoveredToggled: Control
@export var spritePressedToggled: Control
@export var spriteDisabledToggled: Control

var buttonComponent: ButtonComponent = ButtonComponent.new()

func _ready():
	buttonComponent.toggleStates = 2
	buttonComponent.toggleOnPress = false
	buttonComponent.stateUpdatedEarly.connect(updateVisuals)
	
	mouse_entered.connect(buttonComponent.hover)
	mouse_exited.connect(buttonComponent.unhover)

func _input(event):	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and buttonComponent.state.isHovered:
			if !buttonComponent.state.isPressed:
				buttonComponent.press()
		elif !event.is_pressed():
			if buttonComponent.state.isPressed:
				buttonComponent.unpress()

func updateVisuals(_oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if newState.isDisabled:
		showDisabled(newState)
	elif newState.isPressed:
		showPressed(newState)
	elif newState.isHovered:
		showHovered(newState)
	else:
		showDefault(newState)

func showDefault(state: ButtonComponent.ButtonState):
	if state.toggleState == 0 or useDefaultScale or useNonToggledScale:
		setScale(scaleDefault)
	else:
		setScale(scaleDefaultToggled)
	if state.toggleState == 0 or useDefaultModulate or useNonToggledModulate:
		modulate = modulateDefault
	else:
		modulate = modulateDefaultToggled
	if state.toggleState == 0 or useDefaultSprite or useNonToggledSprite:
		showOneSprite(spriteDefault)
	else:
		showOneSprite(spriteDefaultToggled)

func showHovered(state: ButtonComponent.ButtonState):
	if useDefaultScale:
		setScale(scaleDefault)
	elif state.toggleState == 0 or useNonToggledScale:
		setScale(scaleHovered)
	else:
		setScale(scaleHoveredToggled)
	if useDefaultModulate:
		modulate = modulateDefault
	elif state.toggleState == 0 or useNonToggledModulate:
		modulate = modulateHovered
	else:
		modulate = modulateHoveredToggled
	if useDefaultSprite:
		showOneSprite(spriteDefault)
	elif state.toggleState == 0 or useNonToggledSprite:
		showOneSprite(spriteHovered)
	else:
		showOneSprite(spriteHoveredToggled)

func showPressed(state: ButtonComponent.ButtonState):
	if useDefaultScale:
		setScale(scaleDefault)
	elif state.toggleState == 0 or useNonToggledScale:
		setScale(scalePressed)
	else:
		setScale(scalePressedToggled)
	if useDefaultModulate:
		modulate = modulateDefault
	elif state.toggleState == 0 or useNonToggledModulate:
		modulate = modulatePressed
	else:
		modulate = modulatePressedToggled
	if useDefaultSprite:
		showOneSprite(spriteDefault)
	elif state.toggleState == 0 or useNonToggledSprite:
		showOneSprite(spritePressed)
	else:
		showOneSprite(spritePressedToggled)

func showDisabled(state: ButtonComponent.ButtonState):
	if useDefaultScale:
		setScale(scaleDefault)
	elif state.toggleState == 0 or useNonToggledScale:
		setScale(scaleDisabled)
	else:
		setScale(scaleDisabledToggled)
	if useDefaultModulate:
		modulate = modulateDefault
	elif state.toggleState == 0 or useNonToggledModulate:
		modulate = modulateDisabled
	else:
		modulate = modulateDisabledToggled
	if useDefaultSprite:
		showOneSprite(spriteDefault)
	elif state.toggleState == 0 or useNonToggledSprite:
		showOneSprite(spriteDisabled)
	else:
		showOneSprite(spriteDisabledToggled)

func showOneSprite(sprite: Control):
	if spriteDefault != null: spriteDefault.visible = false
	if spriteHovered != null: spriteHovered.visible = false
	if spritePressed != null: spritePressed.visible = false
	if spriteDisabled != null: spriteDisabled.visible = false
	if spriteDefaultToggled != null: spriteDefaultToggled.visible = false
	if spriteHoveredToggled != null: spriteHoveredToggled.visible = false
	if spritePressedToggled != null: spritePressedToggled.visible = false
	if spriteDisabledToggled != null: spriteDisabledToggled.visible = false
	if sprite != null: sprite.visible = true

@onready var startLeftAnchor = anchor_left
@onready var startRightAnchor = anchor_right
@onready var startTopAnchor = anchor_top
@onready var startBottomAnchor = anchor_bottom
func setScale(scale_: float):
	var midpoint: Vector2 = Vector2((startLeftAnchor + startRightAnchor) / 2., (startTopAnchor + startBottomAnchor) / 2.)
	var distance: Vector2 = Vector2(midpoint.x - startLeftAnchor, midpoint.y - startTopAnchor) * scale_
	anchor_left = midpoint.x - distance.x
	anchor_right = midpoint.x + distance.x
	anchor_top = midpoint.y - distance.y
	anchor_bottom = midpoint.y + distance.y

func enable():
	buttonComponent.enable()

func disable():
	buttonComponent.disable()
