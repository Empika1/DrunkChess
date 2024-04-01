@tool

extends Label

@onready var initialHeight: float = size.y;
@export var fontSize: float

func _process(delta):
	print(size.y)
	add_theme_font_size_override("font_size", int(fontSize * size.y / initialHeight))
