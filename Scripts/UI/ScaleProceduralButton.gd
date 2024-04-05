extends TextureButton
class_name ScaleProceduralButton

@export var outerAspectRatioContainer: AspectRatioContainer

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

var buttonImprover: ButtonImprover

func _ready():
	buttonImprover = ButtonImprover.new(mouse_entered, mouse_exited, button_down, button_up,
										null, null, [showDefault], [showHovered], [showPressed], 
										[showDisabled], [], [], false)

func showDefault():
	var mat: ShaderMaterial = material as ShaderMaterial
	if (not buttonImprover.buttonIsToggledOn) or useNonToggledScale:
		outerAspectRatioContainer.ratio = scaleDefault
	else:
		outerAspectRatioContainer.ratio = scaleDefaultToggled
	if (not buttonImprover.buttonIsToggledOn) or useNonToggledOuterDistances:
		mat.set_shader_parameter("outerDistances", outerDistancesDefault)
	else:
		mat.set_shader_parameter("outerDistances", outerDistancesDefaultToggled)
	if (not buttonImprover.buttonIsToggledOn) or useNonToggledThickness:
		mat.set_shader_parameter("thickness", thicknessDefault)
	else:
		mat.set_shader_parameter("thickness", thicknessDefaultToggled)
	if (not buttonImprover.buttonIsToggledOn) or useNonToggledOuterRadius:
		mat.set_shader_parameter("outerRadius", outerRadiusDefault)
	else:
		mat.set_shader_parameter("outerRadius", outerRadiusDefaultToggled)
	if (not buttonImprover.buttonIsToggledOn) or useNonToggledNoDistortLength:
		mat.set_shader_parameter("noDistortLength", noDistortLengthDefault)
	else:
		mat.set_shader_parameter("noDistortLength", noDistortLengthDefaultToggled)
	if (not buttonImprover.buttonIsToggledOn) or useNonToggledInsideBgCol:
		mat.set_shader_parameter("insideBgCol", insideBgColDefault)
	else:
		mat.set_shader_parameter("insideBgCol", insideBgColDefaultToggled)
	if (not buttonImprover.buttonIsToggledOn) or useNonToggledOutsideBgCol:
		mat.set_shader_parameter("outsideBgCol", outsideBgColDefault)
	else:
		mat.set_shader_parameter("outsideBgCol", outsideBgColDefaultToggled)
	if (not buttonImprover.buttonIsToggledOn) or useNonToggledLineCol:
		mat.set_shader_parameter("lineCol", lineColDefault)
	else:
		mat.set_shader_parameter("lineCol", lineColDefaultToggled)
	if (not buttonImprover.buttonIsToggledOn) or useNonToggledModulate:
		modulate = modulateDefault
	else:
		modulate = modulateDefaultToggled
	if (not buttonImprover.buttonIsToggledOn) or useNonToggledSprite:
		spriteHovered.visible = false
		spritePressed.visible = false
		spriteDisabled.visible = false
		spriteDefault.visible = true
	else:
		spriteDefault.visible = false
		spriteHovered.visible = false
		spritePressed.visible = false
		spriteDisabled.visible = false
		spriteHoveredToggled.visible = false
		spritePressedToggled.visible = false
		spriteDisabledToggled.visible = false
		spriteDefaultToggled.visible = true

func showHovered():
	var mat: ShaderMaterial = material as ShaderMaterial
	if useDefaultScale:
		outerAspectRatioContainer.ratio = scaleDefault
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledScale:
		outerAspectRatioContainer.ratio = scaleHovered
	else:
		outerAspectRatioContainer.ratio = scaleHoveredToggled
	if useDefaultOuterDistances:
		mat.set_shader_parameter("outerDistances", outerDistancesDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledOuterDistances:
		mat.set_shader_parameter("outerDistances", outerDistancesHovered)
	else:
		mat.set_shader_parameter("outerDistances", outerDistancesHoveredToggled)
	if useDefaultThickness:
		mat.set_shader_parameter("thickness", thicknessDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledThickness:
		mat.set_shader_parameter("thickness", thicknessHovered)
	else:
		mat.set_shader_parameter("thickness", thicknessHoveredToggled)
	if useDefaultOuterRadius:
		mat.set_shader_parameter("outerRadius", outerRadiusDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledOuterRadius:
		mat.set_shader_parameter("outerRadius", outerRadiusHovered)
	else:
		mat.set_shader_parameter("outerRadius", outerRadiusHoveredToggled)
	if useDefaultNoDistortLength:
		mat.set_shader_parameter("noDistortLength", noDistortLengthDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledNoDistortLength:
		mat.set_shader_parameter("noDistortLength", noDistortLengthHovered)
	else:
		mat.set_shader_parameter("noDistortLength", noDistortLengthHoveredToggled)
	if useDefaultInsideBgCol:
		mat.set_shader_parameter("insideBgCol", insideBgColDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledInsideBgCol:
		mat.set_shader_parameter("insideBgCol", insideBgColHovered)
	else:
		mat.set_shader_parameter("insideBgCol", insideBgColHoveredToggled)
	if useDefaultOutsideBgCol:
		mat.set_shader_parameter("outsideBgCol", outsideBgColDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledOutsideBgCol:
		mat.set_shader_parameter("outsideBgCol", outsideBgColHovered)
	else:
		mat.set_shader_parameter("outsideBgCol", outsideBgColHoveredToggled)
	if useDefaultLineCol:
		mat.set_shader_parameter("lineCol", lineColDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledLineCol:
		mat.set_shader_parameter("lineCol", lineColHovered)
	else:
		mat.set_shader_parameter("lineCol", lineColHoveredToggled)
	if useDefaultModulate:
		modulate = modulateDefault
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledModulate:
		modulate = modulateHovered
	else:
		modulate = modulateHoveredToggled
	if useDefaultSprite:
		spriteDefault.visible = true
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledSprite:
		spriteDefault.visible = false
		spritePressed.visible = false
		spriteDisabled.visible = false
		spriteHovered.visible = true
	else:
		spriteDefault.visible = false
		spriteHovered.visible = false
		spritePressed.visible = false
		spriteDisabled.visible = false
		spriteDefaultToggled.visible = false
		spritePressedToggled.visible = false
		spriteDisabledToggled.visible = false
		spriteHoveredToggled.visible = true

func showPressed():
	var mat: ShaderMaterial = material as ShaderMaterial
	if useDefaultScale:
		outerAspectRatioContainer.ratio = scaleDefault
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledScale:
		outerAspectRatioContainer.ratio = scalePressed
	else:
		outerAspectRatioContainer.ratio = scalePressedToggled
	if useDefaultOuterDistances:
		mat.set_shader_parameter("outerDistances", outerDistancesDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledOuterDistances:
		mat.set_shader_parameter("outerDistances", outerDistancesPressed)
	else:
		mat.set_shader_parameter("outerDistances", outerDistancesPressedToggled)
	if useDefaultThickness:
		mat.set_shader_parameter("thickness", thicknessDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledThickness:
		mat.set_shader_parameter("thickness", thicknessPressed)
	else:
		mat.set_shader_parameter("thickness", thicknessPressedToggled)
	if useDefaultOuterRadius:
		mat.set_shader_parameter("outerRadius", outerRadiusDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledOuterRadius:
		mat.set_shader_parameter("outerRadius", outerRadiusPressed)
	else:
		mat.set_shader_parameter("outerRadius", outerRadiusPressedToggled)
	if useDefaultNoDistortLength:
		mat.set_shader_parameter("noDistortLength", noDistortLengthDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledNoDistortLength:
		mat.set_shader_parameter("noDistortLength", noDistortLengthPressed)
	else:
		mat.set_shader_parameter("noDistortLength", noDistortLengthPressedToggled)
	if useDefaultInsideBgCol:
		mat.set_shader_parameter("insideBgCol", insideBgColDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledInsideBgCol:
		mat.set_shader_parameter("insideBgCol", insideBgColPressed)
	else:
		mat.set_shader_parameter("insideBgCol", insideBgColPressedToggled)
	if useDefaultOutsideBgCol:
		mat.set_shader_parameter("outsideBgCol", outsideBgColDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledOutsideBgCol:
		mat.set_shader_parameter("outsideBgCol", outsideBgColPressed)
	else:
		mat.set_shader_parameter("outsideBgCol", outsideBgColPressedToggled)
	if useDefaultLineCol:
		mat.set_shader_parameter("lineCol", lineColDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledLineCol:
		mat.set_shader_parameter("lineCol", lineColPressed)
	else:
		mat.set_shader_parameter("lineCol", lineColPressedToggled)
	if useDefaultModulate:
		modulate = modulateDefault
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledModulate:
		modulate = modulatePressed
	else:
		modulate = modulatePressedToggled
	if useDefaultSprite:
		spriteDefault.visible = true
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledSprite:
		spriteDefault.visible = false
		spriteHovered.visible = false
		spriteDisabled.visible = false
		spritePressed.visible = true
	else:
		spriteDefault.visible = false
		spriteHovered.visible = false
		spritePressed.visible = false
		spriteDisabled.visible = false
		spriteDefaultToggled.visible = false
		spriteHoveredToggled.visible = false
		spriteDisabledToggled.visible = false
		spritePressedToggled.visible = true

func showDisabled():
	var mat: ShaderMaterial = material as ShaderMaterial
	if useDefaultScale:
		outerAspectRatioContainer.ratio = scaleDefault
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledScale:
		outerAspectRatioContainer.ratio = scaleDisabled
	else:
		outerAspectRatioContainer.ratio = scaleDisabledToggled
	if useDefaultOuterDistances:
		mat.set_shader_parameter("outerDistances", outerDistancesDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledOuterDistances:
		mat.set_shader_parameter("outerDistances", outerDistancesDisabled)
	else:
		mat.set_shader_parameter("outerDistances", outerDistancesDisabledToggled)
	if useDefaultThickness:
		mat.set_shader_parameter("thickness", thicknessDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledThickness:
		mat.set_shader_parameter("thickness", thicknessDisabled)
	else:
		mat.set_shader_parameter("thickness", thicknessDisabledToggled)
	if useDefaultOuterRadius:
		mat.set_shader_parameter("outerRadius", outerRadiusDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledOuterRadius:
		mat.set_shader_parameter("outerRadius", outerRadiusDisabled)
	else:
		mat.set_shader_parameter("outerRadius", outerRadiusDisabledToggled)
	if useDefaultNoDistortLength:
		mat.set_shader_parameter("noDistortLength", noDistortLengthDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledNoDistortLength:
		mat.set_shader_parameter("noDistortLength", noDistortLengthDisabled)
	else:
		mat.set_shader_parameter("noDistortLength", noDistortLengthDisabledToggled)
	if useDefaultInsideBgCol:
		mat.set_shader_parameter("insideBgCol", insideBgColDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledInsideBgCol:
		mat.set_shader_parameter("insideBgCol", insideBgColDisabled)
	else:
		mat.set_shader_parameter("insideBgCol", insideBgColDisabledToggled)
	if useDefaultOutsideBgCol:
		mat.set_shader_parameter("outsideBgCol", outsideBgColDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledOutsideBgCol:
		mat.set_shader_parameter("outsideBgCol", outsideBgColDisabled)
	else:
		mat.set_shader_parameter("outsideBgCol", outsideBgColDisabledToggled)
	if useDefaultLineCol:
		mat.set_shader_parameter("lineCol", lineColDefault)
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledLineCol:
		mat.set_shader_parameter("lineCol", lineColDisabled)
	else:
		mat.set_shader_parameter("lineCol", lineColDisabledToggled)
	if useDefaultModulate:
		modulate = modulateDefault
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledModulate:
		modulate = modulateDisabled
	else:
		modulate = modulateDisabledToggled
	if useDefaultSprite:
		spriteDefault.visible = true
	elif (not buttonImprover.buttonIsToggledOn) or useNonToggledSprite:
		spriteDefault.visible = false
		spriteHovered.visible = false
		spritePressed.visible = false
		spriteDisabled.visible = true
	else:
		spriteDefault.visible = false
		spriteHovered.visible = false
		spritePressed.visible = false
		spriteDisabled.visible = false
		spriteDefaultToggled.visible = false
		spriteHoveredToggled.visible = false
		spritePressedToggled.visible = false
		spriteDisabledToggled.visible = true

func disable():
	buttonImprover.disableButton()

func enable():
	buttonImprover.enableButton()
