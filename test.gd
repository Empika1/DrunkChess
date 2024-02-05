extends Node2D

# Speed at which the player moves
var speed: float = 200

func _ready():
	var whiteKing: Piece = Piece.new(Vector2i(768, 768), Piece.PieceType.KING, Piece.PieceColor.WHITE)
	var blackKing: Piece = Piece.new(Vector2i(5000, 5000), Piece.PieceType.KING, Piece.PieceColor.BLACK)
	var board: BoardState = BoardState.newStartingState([whiteKing, blackKing])
	print(BoardState.StateResult.keys()[board.result])
	

# Called every frame
func _process(_delta: float) -> void:
	# Check if the "W" key is pressed
	if Input.is_key_pressed(KEY_W):
		# Move the player upwards
		position += Vector2(1, 0)
