@tool

extends Control

enum FitType {
	FIT_WIDTH,
	FIT_HEIGHT,
	FIT,
	COVER
}

var initialHeight: float = 0.;
var initialWidth: float = 0.;
@export var fontSize: float
@export var fitType: FitType
@export var label: Control
@export var resetInEditor: bool
func _process(_delta: float):
	if resetInEditor:
		initialHeight = 0
		resetInEditor = false

	if initialHeight == 0 and size.y != 0:
		initialWidth = size.x
		initialHeight = size.y
	
	var wantedSize: int = 0
	match fitType:
		FitType.FIT_WIDTH:
			wantedSize = int(fontSize * size.x / initialWidth)
		FitType.FIT_HEIGHT:
			wantedSize = int(fontSize * size.y / initialHeight)
		FitType.FIT:
			wantedSize = min(int(fontSize * size.x / initialWidth), int(fontSize * size.y / initialHeight))
		FitType.COVER:
			wantedSize = max(int(fontSize * size.x / initialWidth), int(fontSize * size.y / initialHeight))
	
	if label.get_theme_font_size("font_size") != wantedSize:
		label.add_theme_font_size_override("font_size", wantedSize)
