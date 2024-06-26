extends RefCounted
class_name BoardState

enum StateResult {
	VALID,
	WIN_WHITE,
	WIN_BLACK,
	DRAW,
	START_PIECE_OUTSIDE_BOARD,
	START_PIECE_OVERLAPS_PIECE,
	START_NO_WHITE_KING,
	START_NO_BLACK_KING,
	START_MULTIPLE_WHITE_KINGS,
	START_MULTIPLE_BLACK_KINGS,
	START_NONPOSITIVE_WHITE_TIME,
	START_NONPOSITIVE_BLACK_TIME,
	MOVE_ONE_PIECE_MOVED_PIECE_DOESNT_EXIST,
	MOVE_ONE_PIECE_MOVED_PIECE_WRONG_COLOR,
	MOVE_NORMAL_MOVED_TO_PROMOTION_POSITION,
	MOVE_PROMOTION_PROMOTED_FROM_INVALID_TYPE,
	MOVE_PROMOTION_PROMOTED_TO_INVALID_TYPE,
	MOVE_PROMOTION_PROMOTED_IN_INVALID_POSITION,
	MOVE_CASTLE_MOVED_KING_DOESNT_EXIST,
	MOVE_CASTLE_MOVED_ROOK_DOESNT_EXIST,
	MOVE_CASTLE_KING_IS_NOT_KING,
	MOVE_CASTLE_ROOK_IS_NOT_ROOK,
	MOVE_CASTLE_KING_WRONG_COLOR,
	MOVE_CASTLE_ROOK_WRONG_COLOR,
	MOVE_CASTLE_KING_ALREADY_MOVED,
	MOVE_CASTLE_KING_NOT_AT_DEFAULT_START_POS,
	MOVE_CASTLE_ROOK_ALREADY_MOVED,
	MOVE_CASTLE_ROOK_NOT_AT_DEFAULT_START_POS,
	MOVE_CASTLE_CASTLING_THROUGH_SAME_COLOR_PIECE,
	MOVE_CASTLE_CASTLING_THROUGH_OPPOSITE_COLOR_PIECE,
	MOVE_CASTLE_IN_CHECK,
	NULL_STATE_RESULT,
}

class StartSettings:
	enum AssistMode {
		NONE,
		MOVE_ARROWS,
		ANALYSIS
	}
	
	var isTimed: bool
	var startingTime: float
	var assistMode: AssistMode
	
	func _init(assistMode_: AssistMode, isTimed_: bool, startingTime_: float = -1):
		isTimed = isTimed_
		startingTime = startingTime_
		assistMode = assistMode_

var pieces: Array[Piece]
var capturedPieces: Array[Piece]
var turnToMove: Piece.PieceColor
var result: StateResult
var previousState: BoardState
var previousMove: Move #the move applied to the previous state to get here
var startSettings: StartSettings
var whiteTime: float #the latest time that white has, updated mutably
var blackTime: float #same

enum DrawState {NONE, WHITE_OFFERED, BLACK_OFFERED, WHITE_OFFERED_ACCEPTED, 
				BLACK_OFFERED_ACCEPTED, WHITE_OFFERED_REJECTED, BLACK_OFFERED_REJECTED}
var drawState: DrawState = DrawState.NONE #has a draw been offered

var movePoints: Array[PieceLogic.PieceMovePoints]
var piecesCanCapture: Array[Array]
var castlePieces: PieceLogic.CastlePieces
var castlePoints: PieceLogic.CastlePoints

func _init(pieces_: Array[Piece], capturedPieces_: Array[Piece], turnToMove_: Piece.PieceColor, 
	result_: StateResult, previousState_: BoardState, previousMove_: Move, 
	movePoints_: Array[PieceLogic.PieceMovePoints], piecesCanCapture_: Array[Array], 
	castlePieces_: PieceLogic.CastlePieces, castlePoints_: PieceLogic.CastlePoints, 
	startSettings_: StartSettings, whiteTime_: float, blackTime_: float, drawState_: DrawState):
		
	pieces = pieces_
	capturedPieces = capturedPieces_
	turnToMove = turnToMove_
	result = result_
	previousState = previousState_
	previousMove = previousMove_
	startSettings = startSettings_
	whiteTime = whiteTime_
	blackTime = blackTime_
	movePoints = movePoints_
	piecesCanCapture = piecesCanCapture_
	castlePieces = castlePieces_
	castlePoints = castlePoints_
	startSettings = startSettings_
	whiteTime = whiteTime_
	blackTime = blackTime_
	drawState = drawState_

static func newStartingState(pieces_: Array[Piece], startSettings_: StartSettings) -> BoardState:
	var state: BoardState = BoardState.new(pieces_, [], Piece.PieceColor.WHITE, StateResult.VALID, 
		null, null, [], [], null, null, startSettings_, startSettings_.startingTime, 
		startSettings_.startingTime, DrawState.NONE)
	state.result = BoardLogic.validateStartingState(state)
	state.addMoveInfo()
	return state
	
static func newDefaultStartingState(startSettings_: StartSettings) -> BoardState:
	var startPieces: Array[Piece] = []
	
	var firstRowBlackY: int = Piece.boardSize / 16
	var secondRowBlackY: int = Piece.boardSize * 3 / 16
	var firstRowWhiteY: int = Piece.boardSize - firstRowBlackY
	var secondRowWhiteY: int = Piece.boardSize - secondRowBlackY
	var pieceOrder: Array[Piece.PieceType] = [Piece.PieceType.ROOK, Piece.PieceType.KNIGHT, Piece.PieceType.BISHOP, Piece.PieceType.QUEEN, 
											  Piece.PieceType.KING, Piece.PieceType.BISHOP, Piece.PieceType.KNIGHT, Piece.PieceType.ROOK]
	for i: int in range(8):
		var x: int = Piece.boardSize / 16 + Piece.boardSize * i / 8
		startPieces.append(Piece.new(Vector2i(x, firstRowBlackY), pieceOrder[i], Piece.PieceColor.BLACK))
		startPieces.append(Piece.new(Vector2i(x, firstRowWhiteY), pieceOrder[i], Piece.PieceColor.WHITE))
		
		startPieces.append(Piece.new(Vector2i(x, secondRowBlackY), Piece.PieceType.PAWN, Piece.PieceColor.BLACK))
		startPieces.append(Piece.new(Vector2i(x, secondRowWhiteY), Piece.PieceType.PAWN, Piece.PieceColor.WHITE))
	var state: BoardState = BoardState.newStartingState(startPieces, startSettings_)
	return state

func addMoveInfo():
	movePoints = []
	piecesCanCapture = []
	for piece: Piece in pieces:
		var movePoints_: PieceLogic.PieceMovePoints = PieceLogic.calculateMovePoints(piece, pieces)
		var piecesCanCapture_: Array[Piece] = PieceLogic.piecesCanCapture(piece, pieces, movePoints_)
		movePoints.append(movePoints_)
		piecesCanCapture.append(piecesCanCapture_)
	
	castlePieces = PieceLogic.availableCastlePieces(pieces, turnToMove)
	castlePoints = PieceLogic.availableCastlePoints(pieces, turnToMove, castlePieces, movePoints, piecesCanCapture)

func makeMove(move_: Move) -> BoardState:
	var state: BoardState = BoardLogic.makeMove(self, move_)
	state.addMoveInfo()
	return state

func updateTimer(newTime: float) -> void: #JANK: this is logic but isnt in boardlogic
	if startSettings.isTimed:
		if result != StateResult.VALID:
			return
		
		if turnToMove == Piece.PieceColor.WHITE:
			whiteTime = maxf(newTime, 0)
			if whiteTime == 0:
				result = StateResult.WIN_BLACK
		else:
			blackTime = maxf(newTime, 0)
			if blackTime == 0:
				result = StateResult.WIN_WHITE

func offerDraw() -> void: #JANK: this is logic but isnt in boardlogic
	if turnToMove == Piece.PieceColor.WHITE:
		drawState = DrawState.WHITE_OFFERED
	else:
		drawState = DrawState.BLACK_OFFERED

func rejectDraw() -> void: #JANK: this is logic but isnt in boardlogic
	if drawState == DrawState.BLACK_OFFERED:
		drawState = DrawState.BLACK_OFFERED_REJECTED
	elif drawState == DrawState.WHITE_OFFERED:
		drawState = DrawState.WHITE_OFFERED_REJECTED

func confirmDraw() -> void: #JANK: this is logic but isnt in boardlogic
	if drawState == DrawState.BLACK_OFFERED:
		drawState = DrawState.BLACK_OFFERED_ACCEPTED
		result = StateResult.DRAW
	elif drawState == DrawState.WHITE_OFFERED:
		drawState = DrawState.WHITE_OFFERED_ACCEPTED
		result = StateResult.DRAW

func getPreviousWhiteTime() -> float:
	if previousState == null:
		return startSettings.startingTime
	else:
		return previousState.whiteTime

func getPreviousBlackTime() -> float:
	if previousState == null:
		return startSettings.startingTime
	else:
		return previousState.blackTime
	
func prepareForNext() -> BoardState:
	var newPieces: Array[Piece] = []
	for piece in pieces:
		newPieces.append(piece.duplicate())
	
	var newCapturedPieces: Array[Piece] = []
	for piece in capturedPieces:
		newCapturedPieces.append(piece.duplicate())
	
	return BoardState.new(newPieces, newCapturedPieces, turnToMove, result, previousState, previousMove, 
		movePoints, piecesCanCapture, null, null, startSettings, whiteTime, blackTime, drawState)

func findPieceIndex(piece: Piece) -> int:
	if piece == null:
		return -1
	for i in range(len(pieces)):
		if pieces[i].valueEquals(piece):
			return i
	return -1

func toString() -> String:
	var strn = "State:\nPieces:\n"
	for i: Piece in pieces:
		strn += i.toString() + "\n"
	strn += "Captured Pieces:\n"
	for i: Piece in capturedPieces:
		strn += i.toString() + "\n"
	strn += "Turn to move: " + Piece.PieceColor.keys()[turnToMove] + "\n"
	strn += "Result: " + StateResult.keys()[result]
	return strn
