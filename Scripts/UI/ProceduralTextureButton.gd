@tool

extends TextureButton
@export var outerDistancesDefault: Vector4
@export var outerDistancesHovered: Vector4
@export var outerDistancesPressed: Vector4

@export var thicknessDefault: float
@export var thicknessHovered: float
@export var thicknessPressed: float

@export var outerRadiusDefault: float
@export var outerRadiusHovered: float
@export var outerRadiusPressed: float

@export var noDistortLengthDefault: float
@export var noDistortLengthHovered: float
@export var noDistortLengthPressed: float

@export var insideBgColDefault: Color
@export var insideBgColHovered: Color
@export var insideBgColPressed: Color

@export var outsideBgColDefault: Color
@export var outsideBgColHovered: Color
@export var outsideBgColPressed: Color

@export var lineColDefault: Color
@export var lineColHovered: Color
@export var lineColPressed: Color

var isHovered: bool
var isPressed: bool

func _ready():
	mouse_entered.connect(_hover)
	mouse_exited.connect(_unhover)
	button_down.connect(_press)
	button_up.connect(_unpress)
	_unhover()

func _hover():
	isHovered = true
	updateVisualState()

func _unhover():
	isHovered = false
	updateVisualState()

func _press():
	isPressed = true
	updateVisualState()

func _unpress():
	isPressed = false
	updateVisualState()

func updateVisualState():
	if isPressed:
		showPressed()
	elif isHovered:
		showHovered()
	else:
		showDefault()

func showDefault():
	var mat: ShaderMaterial = material as ShaderMaterial
	mat.set_shader_parameter("outerDistances", outerDistancesDefault)
	mat.set_shader_parameter("thickness", thicknessDefault)
	mat.set_shader_parameter("outerRadius", outerRadiusDefault)
	mat.set_shader_parameter("insideBgCol", insideBgColDefault)
	mat.set_shader_parameter("outsideBgCol", outsideBgColDefault)
	mat.set_shader_parameter("lineCol", lineColDefault)

func showHovered():
	var mat: ShaderMaterial = material as ShaderMaterial
	mat.set_shader_parameter("outerDistances", outerDistancesHovered)
	mat.set_shader_parameter("thickness", thicknessHovered)
	mat.set_shader_parameter("outerRadius", outerRadiusHovered)
	mat.set_shader_parameter("insideBgCol", insideBgColHovered)
	mat.set_shader_parameter("outsideBgCol", outsideBgColHovered)
	mat.set_shader_parameter("lineCol", lineColHovered)

func showPressed():
	var mat: ShaderMaterial = material as ShaderMaterial
	mat.set_shader_parameter("outerDistances", outerDistancesPressed)
	mat.set_shader_parameter("thickness", thicknessPressed)
	mat.set_shader_parameter("outerRadius", outerRadiusPressed)
	mat.set_shader_parameter("insideBgCol", insideBgColPressed)
	mat.set_shader_parameter("outsideBgCol", outsideBgColPressed)
	mat.set_shader_parameter("lineCol", lineColPressed)
