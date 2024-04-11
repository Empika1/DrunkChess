extends TextureButton
class_name BorderScaleButton

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

@export var useDefaultOuterDistances: bool
@export var outerDistancesDefault: Vector4
@export var outerDistancesHovered: Vector4
@export var outerDistancesPressed: Vector4
@export var outerDistancesDisabled: Vector4
@export var useNonToggledOuterDistances: bool
@export var outerDistancesDefaultToggled: Vector4
@export var outerDistancesHoveredToggled: Vector4
@export var outerDistancesPressedToggled: Vector4
@export var outerDistancesDisabledToggled: Vector4

@export var useDefaultThickness: bool
@export var thicknessDefault: float
@export var thicknessHovered: float
@export var thicknessPressed: float
@export var thicknessDisabled: float
@export var useNonToggledThickness: bool
@export var thicknessDefaultToggled: float
@export var thicknessHoveredToggled: float
@export var thicknessPressedToggled: float
@export var thicknessDisabledToggled: float

@export var useDefaultOuterRadius: bool
@export var outerRadiusDefault: float
@export var outerRadiusHovered: float
@export var outerRadiusPressed: float
@export var outerRadiusDisabled: float
@export var useNonToggledOuterRadius: bool
@export var outerRadiusDefaultToggled: float
@export var outerRadiusHoveredToggled: float
@export var outerRadiusPressedToggled: float
@export var outerRadiusDisabledToggled: float

@export var useDefaultNoDistortLength: bool
@export var noDistortLengthDefault: float
@export var noDistortLengthHovered: float
@export var noDistortLengthPressed: float
@export var noDistortLengthDisabled: float
@export var useNonToggledNoDistortLength: bool
@export var noDistortLengthDefaultToggled: float
@export var noDistortLengthHoveredToggled: float
@export var noDistortLengthPressedToggled: float
@export var noDistortLengthDisabledToggled: float

@export var useDefaultInsideBgCol: bool
@export var insideBgColDefault: Color
@export var insideBgColHovered: Color
@export var insideBgColPressed: Color
@export var insideBgColDisabled: Color
@export var useNonToggledInsideBgCol: bool
@export var insideBgColDefaultToggled: Color
@export var insideBgColHoveredToggled: Color
@export var insideBgColPressedToggled: Color
@export var insideBgColDisabledToggled: Color

@export var useDefaultOutsideBgCol: bool
@export var outsideBgColDefault: Color
@export var outsideBgColHovered: Color
@export var outsideBgColPressed: Color
@export var outsideBgColDisabled: Color
@export var useNonToggledOutsideBgCol: bool
@export var outsideBgColDefaultToggled: Color
@export var outsideBgColHoveredToggled: Color
@export var outsideBgColPressedToggled: Color
@export var outsideBgColDisabledToggled: Color

@export var useDefaultLineCol: bool
@export var lineColDefault: Color
@export var lineColHovered: Color
@export var lineColPressed: Color
@export var lineColDisabled: Color
@export var useNonToggledLineCol: bool
@export var lineColDefaultToggled: Color
@export var lineColHoveredToggled: Color
@export var lineColPressedToggled: Color
@export var lineColDisabledToggled: Color

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

@export var test: bool

var buttonComponent: ButtonComponent = ButtonComponent.new()

func _ready():
	buttonComponent.toggleStates = 2
	buttonComponent.toggleOnPress = false
	buttonComponent.stateUpdated.connect(updateVisuals)
	
	mouse_entered.connect(buttonComponent.hover)
	mouse_exited.connect(buttonComponent.unhover)
	visibility_changed.connect(
		func(): 
			if !is_visible_in_tree():
				buttonComponent.unpress()
				buttonComponent.unhover())

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
		if test: print("disabled")
		showDisabled(newState)
	elif newState.isPressed:
		if test: print("pressed")
		showPressed(newState)
	elif newState.isHovered:
		if test: print("hovered")
		showHovered(newState)
	else:
		if test: print("idles")
		showDefault(newState)

func showDefault(state: ButtonComponent.ButtonState):
	var mat: ShaderMaterial = material as ShaderMaterial
	if state.toggleState == 0 or useDefaultScale or useNonToggledScale:
		setScale(scaleDefault)
	else:
		setScale(scaleDefaultToggled)
	if state.toggleState == 0 or useDefaultOuterDistances or useNonToggledOuterDistances:
		mat.set_shader_parameter("outerDistances", outerDistancesDefault)
	else:
		mat.set_shader_parameter("outerDistances", outerDistancesDefaultToggled)
	if state.toggleState == 0 or useDefaultThickness or useNonToggledThickness:
		mat.set_shader_parameter("thickness", thicknessDefault)
	else:
		mat.set_shader_parameter("thickness", thicknessDefaultToggled)
	if state.toggleState == 0 or useDefaultOuterRadius or useNonToggledOuterRadius:
		mat.set_shader_parameter("outerRadius", outerRadiusDefault)
	else:
		mat.set_shader_parameter("outerRadius", outerRadiusDefaultToggled)
	if state.toggleState == 0 or useDefaultNoDistortLength or useNonToggledNoDistortLength:
		mat.set_shader_parameter("noDistortLength", noDistortLengthDefault)
	else:
		mat.set_shader_parameter("noDistortLength", noDistortLengthDefaultToggled)
	if state.toggleState == 0 or useDefaultInsideBgCol or useNonToggledInsideBgCol:
		mat.set_shader_parameter("insideBgCol", insideBgColDefault)
	else:
		mat.set_shader_parameter("insideBgCol", insideBgColDefaultToggled)
	if state.toggleState == 0 or useDefaultOutsideBgCol or useNonToggledOutsideBgCol:
		mat.set_shader_parameter("outsideBgCol", outsideBgColDefault)
	else:
		mat.set_shader_parameter("outsideBgCol", outsideBgColDefaultToggled)
	if state.toggleState == 0 or useDefaultLineCol or useNonToggledLineCol:
		mat.set_shader_parameter("lineCol", lineColDefault)
	else:
		mat.set_shader_parameter("lineCol", lineColDefaultToggled)
	if state.toggleState == 0 or useDefaultModulate or useNonToggledModulate:
		modulate = modulateDefault
	else:
		modulate = modulateDefaultToggled
	if state.toggleState == 0 or useDefaultSprite or useNonToggledSprite:
		showOneSprite(spriteDefault)
	else:
		showOneSprite(spriteDefaultToggled)

func showHovered(state: ButtonComponent.ButtonState):
	var mat: ShaderMaterial = material as ShaderMaterial
	if useDefaultScale:
		setScale(scaleDefault)
	elif state.toggleState == 0 or useNonToggledScale:
		setScale(scaleHovered)
	else:
		setScale(scaleHoveredToggled)
	if useDefaultOuterDistances:
		mat.set_shader_parameter("outerDistances", outerDistancesDefault)
	elif state.toggleState == 0 or useNonToggledOuterDistances:
		mat.set_shader_parameter("outerDistances", outerDistancesHovered)
	else:
		mat.set_shader_parameter("outerDistances", outerDistancesHoveredToggled)
	if useDefaultThickness:
		mat.set_shader_parameter("thickness", thicknessDefault)
	elif state.toggleState == 0 or useNonToggledThickness:
		mat.set_shader_parameter("thickness", thicknessHovered)
	else:
		mat.set_shader_parameter("thickness", thicknessHoveredToggled)
	if useDefaultOuterRadius:
		mat.set_shader_parameter("outerRadius", outerRadiusDefault)
	elif state.toggleState == 0 or useNonToggledOuterRadius:
		mat.set_shader_parameter("outerRadius", outerRadiusHovered)
	else:
		mat.set_shader_parameter("outerRadius", outerRadiusHoveredToggled)
	if useDefaultNoDistortLength:
		mat.set_shader_parameter("noDistortLength", noDistortLengthDefault)
	elif state.toggleState == 0 or useNonToggledNoDistortLength:
		mat.set_shader_parameter("noDistortLength", noDistortLengthHovered)
	else:
		mat.set_shader_parameter("noDistortLength", noDistortLengthHoveredToggled)
	if useDefaultInsideBgCol:
		mat.set_shader_parameter("insideBgCol", insideBgColDefault)
	elif state.toggleState == 0 or useNonToggledInsideBgCol:
		mat.set_shader_parameter("insideBgCol", insideBgColHovered)
	else:
		mat.set_shader_parameter("insideBgCol", insideBgColHoveredToggled)
	if useDefaultOutsideBgCol:
		mat.set_shader_parameter("outsideBgCol", outsideBgColDefault)
	elif state.toggleState == 0 or useNonToggledOutsideBgCol:
		mat.set_shader_parameter("outsideBgCol", outsideBgColHovered)
	else:
		mat.set_shader_parameter("outsideBgCol", outsideBgColHoveredToggled)
	if useDefaultLineCol:
		mat.set_shader_parameter("lineCol", lineColDefault)
	elif state.toggleState == 0 or useNonToggledLineCol:
		mat.set_shader_parameter("lineCol", lineColHovered)
	else:
		mat.set_shader_parameter("lineCol", lineColHoveredToggled)
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
	var mat: ShaderMaterial = material as ShaderMaterial
	if useDefaultScale:
		setScale(scaleDefault)
	elif state.toggleState == 0 or useNonToggledScale:
		setScale(scalePressed)
	else:
		setScale(scalePressedToggled)
	if useDefaultOuterDistances:
		mat.set_shader_parameter("outerDistances", outerDistancesDefault)
	elif state.toggleState == 0 or useNonToggledOuterDistances:
		mat.set_shader_parameter("outerDistances", outerDistancesPressed)
	else:
		mat.set_shader_parameter("outerDistances", outerDistancesPressedToggled)
	if useDefaultThickness:
		mat.set_shader_parameter("thickness", thicknessDefault)
	elif state.toggleState == 0 or useNonToggledThickness:
		mat.set_shader_parameter("thickness", thicknessPressed)
	else:
		mat.set_shader_parameter("thickness", thicknessPressedToggled)
	if useDefaultOuterRadius:
		mat.set_shader_parameter("outerRadius", outerRadiusDefault)
	elif state.toggleState == 0 or useNonToggledOuterRadius:
		mat.set_shader_parameter("outerRadius", outerRadiusPressed)
	else:
		mat.set_shader_parameter("outerRadius", outerRadiusPressedToggled)
	if useDefaultNoDistortLength:
		mat.set_shader_parameter("noDistortLength", noDistortLengthDefault)
	elif state.toggleState == 0 or useNonToggledNoDistortLength:
		mat.set_shader_parameter("noDistortLength", noDistortLengthPressed)
	else:
		mat.set_shader_parameter("noDistortLength", noDistortLengthPressedToggled)
	if useDefaultInsideBgCol:
		mat.set_shader_parameter("insideBgCol", insideBgColDefault)
	elif state.toggleState == 0 or useNonToggledInsideBgCol:
		mat.set_shader_parameter("insideBgCol", insideBgColPressed)
	else:
		mat.set_shader_parameter("insideBgCol", insideBgColPressedToggled)
	if useDefaultOutsideBgCol:
		mat.set_shader_parameter("outsideBgCol", outsideBgColDefault)
	elif state.toggleState == 0 or useNonToggledOutsideBgCol:
		mat.set_shader_parameter("outsideBgCol", outsideBgColPressed)
	else:
		mat.set_shader_parameter("outsideBgCol", outsideBgColPressedToggled)
	if useDefaultLineCol:
		mat.set_shader_parameter("lineCol", lineColDefault)
	elif state.toggleState == 0 or useNonToggledLineCol:
		mat.set_shader_parameter("lineCol", lineColPressed)
	else:
		mat.set_shader_parameter("lineCol", lineColPressedToggled)
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
	var mat: ShaderMaterial = material as ShaderMaterial
	if useDefaultScale:
		setScale(scaleDefault)
	elif state.toggleState == 0 or useNonToggledScale:
		setScale(scaleDisabled)
	else:
		setScale(scaleDisabledToggled)
	if useDefaultOuterDistances:
		mat.set_shader_parameter("outerDistances", outerDistancesDefault)
	elif state.toggleState == 0 or useNonToggledOuterDistances:
		mat.set_shader_parameter("outerDistances", outerDistancesDisabled)
	else:
		mat.set_shader_parameter("outerDistances", outerDistancesDisabledToggled)
	if useDefaultThickness:
		mat.set_shader_parameter("thickness", thicknessDefault)
	elif state.toggleState == 0 or useNonToggledThickness:
		mat.set_shader_parameter("thickness", thicknessDisabled)
	else:
		mat.set_shader_parameter("thickness", thicknessDisabledToggled)
	if useDefaultOuterRadius:
		mat.set_shader_parameter("outerRadius", outerRadiusDefault)
	elif state.toggleState == 0 or useNonToggledOuterRadius:
		mat.set_shader_parameter("outerRadius", outerRadiusDisabled)
	else:
		mat.set_shader_parameter("outerRadius", outerRadiusDisabledToggled)
	if useDefaultNoDistortLength:
		mat.set_shader_parameter("noDistortLength", noDistortLengthDefault)
	elif state.toggleState == 0 or useNonToggledNoDistortLength:
		mat.set_shader_parameter("noDistortLength", noDistortLengthDisabled)
	else:
		mat.set_shader_parameter("noDistortLength", noDistortLengthDisabledToggled)
	if useDefaultInsideBgCol:
		mat.set_shader_parameter("insideBgCol", insideBgColDefault)
	elif state.toggleState == 0 or useNonToggledInsideBgCol:
		mat.set_shader_parameter("insideBgCol", insideBgColDisabled)
	else:
		mat.set_shader_parameter("insideBgCol", insideBgColDisabledToggled)
	if useDefaultOutsideBgCol:
		mat.set_shader_parameter("outsideBgCol", outsideBgColDefault)
	elif state.toggleState == 0 or useNonToggledOutsideBgCol:
		mat.set_shader_parameter("outsideBgCol", outsideBgColDisabled)
	else:
		mat.set_shader_parameter("outsideBgCol", outsideBgColDisabledToggled)
	if useDefaultLineCol:
		mat.set_shader_parameter("lineCol", lineColDefault)
	elif state.toggleState == 0 or useNonToggledLineCol:
		mat.set_shader_parameter("lineCol", lineColDisabled)
	else:
		mat.set_shader_parameter("lineCol", lineColDisabledToggled)
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