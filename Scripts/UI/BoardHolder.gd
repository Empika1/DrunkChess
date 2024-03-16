extends Control
class_name BoardHolder

@export var board: Sprite2D

func _ready():
	resized.connect(_sizeChanged)

func _sizeChanged():
	board.position = size * 0.5 - (board.get_rect().size * board.global_scale) * 0.5
	var scaleRatio: float = (board.get_rect().size * board.global_scale).x / min(size.x, size.y)
	board.global_scale /= Vector2(scaleRatio, scaleRatio)
