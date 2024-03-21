extends Node
class_name GameManager

@export var board: Sprite2D
@export var pieceHolder: Node2D

@export var blackDiscard: Button
@export var blackConfirm: Button
@export var whiteDiscard: Button
@export var whiteConfirm: Button

@onready var states: Array[BoardState] = [BoardState.newDefaultStartingState()]

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
		var distanceSquared = (cs.global_position.x - mousePos.x) ** 2 + (cs.global_position.y - mousePos.y) ** 2
		if distanceSquared < (float(c.piece.hitRadius) / Piece.boardSize * getScaledRectSize()) ** 2:
			return cs.piece
	return null

var pieceDragging: Piece #a reference to the piece in the previous state
var piecePlaced: bool
var dragOffset: Vector2i
var attemptedNextState: BoardState
func _process(_delta):
	var mousePos: Vector2i = get_viewport().get_mouse_position()
	if pieceDragging == null && Input.is_action_just_pressed("lmb"):
		var hoveredPiece: Piece = getHoveredPiece(mousePos)
		if hoveredPiece != null and hoveredPiece.color == states[-1].turnToMove:
			pieceDragging = getHoveredPiece(mousePos)
		if pieceDragging != null:
			dragOffset = boardPosToGamePos(pieceDragging.pos) - Vector2(mousePos)
		piecePlaced = false
	
	if pieceDragging != null:
		var move: Move = null
		
		var castlePieces: PieceLogic.CastlePieces = states[-1].castlePieces
		var castlePoints: PieceLogic.CastlePoints = states[-1].castlePoints
		if castlePoints.canCastleLeft and (Vector2(mousePos) - boardPosToGamePos(castlePoints.kingPointLeft)).length_squared() <= boardLengthToGameLength(BoardRenderer.castleRadius) ** 2:
			move = Move.newCastle(castlePieces.king, castlePieces.leftRook)
		if castlePoints.canCastleRight and (Vector2(mousePos) - boardPosToGamePos(castlePoints.kingPointRight)).length_squared() <= boardLengthToGameLength(BoardRenderer.castleRadius) ** 2:
			move = Move.newCastle(castlePieces.king, castlePieces.rightRook)
		
		if move == null:
			var movePos: Vector2i = PieceLogic.closestPosCanMoveTo(pieceDragging, states[-1].pieces, gamePosToBoardPos(mousePos + dragOffset), 
				states[-1].movePoints[states[-1].findPieceIndex(pieceDragging)])
			
			if pieceDragging.type == Piece.PieceType.PAWN and Piece.isPromotionPosition(movePos, states[-1].turnToMove):
				move = Move.newPromotion(pieceDragging, movePos, Piece.PieceType.QUEEN)
			else:
				move = Move.newNormal(pieceDragging, movePos)
		
		attemptedNextState = states[-1].makeMove(move)
		
		if Input.is_action_just_released("lmb"):
			piecePlaced = true
		
		if Input.is_action_just_pressed("lmb") and piecePlaced:
			if (!(whiteDiscard.is_hovered() or blackDiscard.is_hovered()) and 
				attemptedNextState.result in [BoardState.StateResult.VALID, BoardState.StateResult.WIN_BLACK, BoardState.StateResult.WIN_WHITE]):
				states.append(attemptedNextState)
			attemptedNextState = null
			pieceDragging = null
			dragOffset = Vector2i.ZERO	
	
	if states[-1].result in [BoardState.StateResult.WIN_BLACK, BoardState.StateResult.WIN_WHITE]:
		print("hhhhhhhhhhhhhhhhhhhhhhhhhhhhh")
