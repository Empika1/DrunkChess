extends RefCounted
class_name BoardState

enum StateResult {
	VALID,
	WIN_WHITE,
	WIN_BLACK,
	START_PIECE_OUTSIDE_BOARD,
	START_PIECE_OVERLAPS_PIECE,
	START_NO_WHITE_KING,
	START_NO_BLACK_KING,
	START_MULTIPLE_WHITE_KINGS,
	START_MULTIPLE_BLACK_KINGS,
	MOVE_ONE_PIECE_MOVED_PIECE_DOESNT_EXIST,
	MOVE_ONE_PIECE_MOVED_PIECE_WRONG_COLOR,
	MOVE_ONE_PIECE_MOVED_PIECE_OUTSIDE_BOARD,
	MOVE_ONE_PIECE_MOVED_PIECE_OVERLAPS_PIECE_OF_SAME_COLOR,
	MOVE_ONE_PIECE_MOVED_PIECE_OVERLAPS_PIECE_OF_OPPOSITE_COLOR,
	MOVE_PROMOTION_PROMOTED_TO_INVALID_TYPE,
	MOVE_PROMOTION_PROMOTED_IN_INVALID_POSITION,
	MOVE_CASTLE_KING_IS_NOT_KING,
	MOVE_CASTLE_ROOK_IS_NOT_ROOK,
	MOVE_CASTLE_KING_WRONG_COLOR,
	MOVE_CASTLE_ROOK_WRONG_COLOR,
	MOVE_CASTLE_KING_ALREADY_MOVED,
	MOVE_CASTLE_ROOK_ALREADY_MOVED,
	NULL_STATE_RESULT,
}

var pieces: Array[Piece]
var capturedPieces: Array[Piece]
var turnToMove: Piece.PieceColor
var result: StateResult
var previousState: BoardState

func _init(pieces_: Array[Piece], capturedPieces_: Array[Piece], turnToMove_: Piece.PieceColor, result_: StateResult, previousState_: BoardState):
	pieces = pieces_
	capturedPieces = capturedPieces_
	turnToMove = turnToMove_
	result = result_
	previousState = previousState_
	
static func newStartingState(pieces_: Array[Piece]) -> BoardState:
	var state: BoardState = BoardState.new(pieces_, [], Piece.PieceColor.WHITE, StateResult.VALID, null)
	state.result = BoardLogic.validateStartingState(state)
	return state
	
static func newDefaultStartingState() -> BoardState:
	var whiteKing: Piece = Piece.new(Vector2i(768, 768), Piece.PieceType.KING, Piece.PieceColor.WHITE)
	var blackKing: Piece = Piece.new(Vector2i(5000, 5000), Piece.PieceType.KING, Piece.PieceColor.BLACK)
	var randomRook: Piece = Piece.new(Vector2i(2500, 768), Piece.PieceType.ROOK, Piece.PieceColor.WHITE)
	var otherRandomRook: Piece = Piece.new(Vector2i(5900, 768), Piece.PieceType.ROOK, Piece.PieceColor.BLACK)
	var state: BoardState = BoardState.newStartingState([whiteKing, blackKing, randomRook, otherRandomRook])
	state.result = BoardLogic.validateStartingState(state)
	return state

func makeMove(move_: Move) -> BoardState:
	return BoardLogic.makeMove(self, move_).duplicate()
	
func duplicate() -> BoardState:
	var newPieces: Array[Piece] = []
	for piece in pieces:
		newPieces.append(piece.duplicate())
	print("pieces size ", pieces.size(), " ", newPieces.size())
	
	var newCapturedPieces: Array[Piece] = []
	for piece in capturedPieces:
		newPieces.append(piece.duplicate())
	print("captured pieces size ", capturedPieces.size(), " ", newCapturedPieces.size())
		
	return BoardState.new(newPieces, newCapturedPieces, turnToMove, result, previousState)

func toString() -> String:
	var str = "State:\nPieces:\n"
	for i: Piece in pieces:
		str += i.toString() + "\n"
	str += "Captured Pieces:\n"
	for i: Piece in capturedPieces:
		str += i.toString() + "\n"
	str += "Turn to move: " + Piece.PieceColor.keys()[turnToMove] + "\n"
	str += "Result: " + StateResult.keys()[result]
	return str
