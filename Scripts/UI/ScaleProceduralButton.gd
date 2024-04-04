extends TextureButton
class_name ScaleProceduralButton

@export var outerAspectRatioContainer: AspectRatioContainer
@export var scaleDefault: float
@export var scaleHovered: float
@export var scalePressed: float
@export var scaleDisabled: float

@export var outerDistancesDefault: Vector4
@export var outerDistancesHovered: Vector4
@export var outerDistancesPressed: Vector4
@export var outerDistancesDisabled: Vector4

@export var thicknessDefault: float
@export var thicknessHovered: float
@export var thicknessPressed: float
@export var thicknessDisabled: float

@export var outerRadiusDefault: float
@export var outerRadiusHovered: float
@export var outerRadiusPressed: float
@export var outerRadiusDisabled: float

@export var noDistortLengthDefault: float
@export var noDistortLengthHovered: float
@export var noDistortLengthPressed: float
@export var noDistortLengthDisabled: float

@export var insideBgColDefault: Color
@export var insideBgColHovered: Color
@export var insideBgColPressed: Color
@export var insideBgColDisabled: Color

@export var outsideBgColDefault: Color
@export var outsideBgColHovered: Color
@export var outsideBgColPressed: Color
@export var outsideBgColDisabled: Color

@export var lineColDefault: Color
@export var lineColHovered: Color
@export var lineColPressed: Color
@export var lineColDisabled: Color

@export var modulateDefault: Color
@export var modulateHovered: Color
@export var modulatePressed: Color
@export var modulateDisabled: Color

@export var spriteDefault: Control
@export var spriteHovered: Control
@export var spritePressed: Control
@export var spriteDisabled: Control

var buttonImprover: ButtonImprover

func _ready():
	buttonImprover = ButtonImprover.new(mouse_entered, mouse_exited, button_down, button_up,
										null, null, [showDefault], [showHovered], [showPressed], [showDisabled])

func showDefault():
	outerAspectRatioContainer.ratio = scaleDefault
	modulate = modulateDefault
	spriteHovered.visible = false
	spritePressed.visible = false
	spriteDisabled.visible = false
	spriteDefault.visible = true
	
	var mat: ShaderMaterial = material as ShaderMaterial
	mat.set_shader_parameter("outerDistances", outerDistancesDefault)
	mat.set_shader_parameter("thickness", thicknessDefault)
	mat.set_shader_parameter("outerRadius", outerRadiusDefault)
	mat.set_shader_parameter("insideBgCol", insideBgColDefault)
	mat.set_shader_parameter("outsideBgCol", outsideBgColDefault)
	mat.set_shader_parameter("lineCol", lineColDefault)

func showHovered():
	outerAspectRatioContainer.ratio = scaleHovered
	modulate = modulateHovered	
	spriteDefault.visible = false
	spritePressed.visible = false
	spriteDisabled.visible = false
	spriteHovered.visible = true
	
	var mat: ShaderMaterial = material as ShaderMaterial
	mat.set_shader_parameter("outerDistances", outerDistancesHovered)
	mat.set_shader_parameter("thickness", thicknessHovered)
	mat.set_shader_parameter("outerRadius", outerRadiusHovered)
	mat.set_shader_parameter("insideBgCol", insideBgColHovered)
	mat.set_shader_parameter("outsideBgCol", outsideBgColHovered)
	mat.set_shader_parameter("lineCol", lineColHovered)

func showPressed():
	outerAspectRatioContainer.ratio = scalePressed
	modulate = modulatePressed
	spriteDefault.visible = false
	spriteHovered.visible = false
	spriteDisabled.visible = false
	spritePressed.visible = true
	
	var mat: ShaderMaterial = material as ShaderMaterial
	mat.set_shader_parameter("outerDistances", outerDistancesPressed)
	mat.set_shader_parameter("thickness", thicknessPressed)
	mat.set_shader_parameter("outerRadius", outerRadiusPressed)
	mat.set_shader_parameter("insideBgCol", insideBgColPressed)
	mat.set_shader_parameter("outsideBgCol", outsideBgColPressed)
	mat.set_shader_parameter("lineCol", lineColPressed)

func showDisabled():
	outerAspectRatioContainer.ratio = scaleDisabled
	modulate = modulateDisabled
	spriteDefault.visible = false
	spriteHovered.visible = false
	spritePressed.visible = false
	spriteDisabled.visible = true
	
	var mat: ShaderMaterial = material as ShaderMaterial
	mat.set_shader_parameter("outerDistances", outerDistancesDisabled)
	mat.set_shader_parameter("thickness", thicknessDisabled)
	mat.set_shader_parameter("outerRadius", outerRadiusDisabled)
	mat.set_shader_parameter("insideBgCol", insideBgColDisabled)
	mat.set_shader_parameter("outsideBgCol", outsideBgColDisabled)
	mat.set_shader_parameter("lineCol", lineColDisabled)

func disable():
	buttonImprover.disableButton()

func enable():
	buttonImprover.enableButton()
