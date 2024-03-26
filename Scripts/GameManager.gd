extends Node
class_name GameManager

@export var board: Sprite2D
@export var pieceHolder: Node2D

@onready var states: Array[BoardState] = [BoardState.newDefaultStartingState(BoardState.StartSettings.new(BoardState.StartSettings.AssistMode.MOVE_ARROWS, true, 300))]

func getScaledRectSize():
	return (board.get_rect().size * board.global_scale).x

func boardLengthToGameLength(boardLength: int) -> float:
	return boardLength * getScaledRectSize() / float(Piece.boardSize)

func boardPosToGamePos(boardPos: Vector2i) -> Vector2:
	return Vector2(boardLengthToGameLength(boardPos.x) + board.global_position.x, boardLengthToGameLength(boardPos.y) + board.global_position.y)

func gameLengthToBoardLength(gameLength: float) -> int:
	return int(gameLength * float(Piece.boardSize) / getScaledRectSize())

func gamePosToBoardPos(gamePos: Vector2) -> Vector2i:
	return Vector2i(gameLengthToBoardLength(gamePos.x - board.global_position.x), gameLengthToBoardLength(gamePos.y - board.global_position.y))

func getHoveredPiece(mousePos: Vector2i) -> Piece:
	for c in pieceHolder.get_children():
		var cs = c as DraggablePiece
		var distanceSquared = (cs.global_position - Vector2(mousePos)).length_squared()
		if cs.piece != null and distanceSquared < boardLengthToGameLength(cs.piece.hitRadius) ** 2:
			return cs.piece
	return null

var pieceHovering: Piece = null #a reference to the piece in the previous state
var pieceDragging: Piece = null #a reference to the piece in the previous state
var dragOffset: Vector2i = Vector2i(0, 0)
var dragPos: Vector2i = Vector2i(0, 0)
var isPiecePlaced: bool = false
var attemptedNextState: BoardState = null
@onready var timeAtStartOfTurn: float = float(Time.get_ticks_msec()) / 1000
const dragBorder: Vector2i = Vector2i(Piece.squareSize, Piece.squareSize)
func _process(_delta):		
	#determine hovered piece
	var mousePosGame: Vector2i = get_viewport().get_mouse_position()
	var mousePosBoard: Vector2i = gamePosToBoardPos(mousePosGame)
	pieceHovering = getHoveredPiece(mousePosGame)
	if pieceHovering != null and pieceHovering.color != states[-1].turnToMove:
		pieceHovering = null
	
	#determine piece being dragged
	if pieceHovering != null and pieceDragging == null && Input.is_action_just_pressed("lmb"):
		pieceDragging = pieceHovering
		dragOffset = pieceDragging.pos - mousePosBoard
		isPiecePlaced = false
	
	#make move with piece being dragged
	if pieceDragging != null:
		dragPos = mousePosBoard + dragOffset
		var move: Move = null
		
		#find if the move is a castle move
		var castlePieces: PieceLogic.CastlePieces = states[-1].castlePieces
		var castlePoints: PieceLogic.CastlePoints = states[-1].castlePoints
		if castlePoints.canCastleLeft and (mousePosBoard - castlePoints.kingPointLeft).length_squared() <= BoardRenderer.castleRadius ** 2:
			move = Move.newCastle(castlePieces.king, castlePieces.leftRook)
		if castlePoints.canCastleRight and (mousePosBoard - castlePoints.kingPointRight).length_squared() <= BoardRenderer.castleRadius ** 2:
			move = Move.newCastle(castlePieces.king, castlePieces.rightRook)
		
		#if not castle, make normal or promotion move
		if move == null:
			var movePos: Vector2i = PieceLogic.closestPosCanMoveTo(pieceDragging, states[-1].pieces, dragPos, 
				states[-1].movePoints[states[-1].findPieceIndex(pieceDragging)])
			
			if pieceDragging.type == Piece.PieceType.PAWN and Piece.isPromotionPosition(movePos, states[-1].turnToMove):
				move = Move.newPromotion(pieceDragging, movePos, Piece.PieceType.QUEEN)
			else:
				move = Move.newNormal(pieceDragging, movePos)
		
		#check to see if the player is cancelling the move
		if mousePosBoard.x < -dragBorder.x or mousePosBoard.y < -dragBorder.y or mousePosBoard.x > Piece.boardSize + dragBorder.x or mousePosBoard.y > Piece.boardSize + dragBorder.y:
			attemptedNextState = null
		else:
			attemptedNextState = states[-1].makeMove(move)
		
		if Input.is_action_just_released("lmb"):
			if attemptedNextState != null:
				isPiecePlaced = true
			else:
				pieceDragging = null
		
		if Input.is_action_just_pressed("lmb") and isPiecePlaced:
			if (attemptedNextState != null and 
				attemptedNextState.result in [BoardState.StateResult.VALID, BoardState.StateResult.WIN_BLACK, BoardState.StateResult.WIN_WHITE]):
				states.append(attemptedNextState)
			attemptedNextState = null
			timeAtStartOfTurn = float(Time.get_ticks_msec()) / 1000
			pieceDragging = null
			
	#update timer
	if states[-1].turnToMove == Piece.PieceColor.WHITE:
		states[-1].updateTimer(states[-1].getPreviousWhiteTime() - (float(Time.get_ticks_msec()) / 1000 - timeAtStartOfTurn))
	else:
		states[-1].updateTimer(states[-1].getPreviousBlackTime() - (float(Time.get_ticks_msec()) / 1000 - timeAtStartOfTurn))
	
	if states[-1].result in [BoardState.StateResult.WIN_BLACK, BoardState.StateResult.WIN_WHITE]:
		print("hhhhhhhhhhhhhhhhhhhhhhhhhhhhh")
