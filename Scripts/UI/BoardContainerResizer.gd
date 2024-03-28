@tool
extends Node
@export var boardSquare: Control
@export var mainContainer: AspectRatioContainer
@export var r: float

func _ready():
	if not Engine.is_editor_hint():
		updateRatio()

func _process(_delta):
	if Engine.is_editor_hint():
		updateRatio()

func updateRatio() -> void:
	boardSquare.size_flags_stretch_ratio = 2 * r / (1 - r)
	mainContainer.ratio = r
