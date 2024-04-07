extends Node
class_name GameManager

@export var board: TextureRect
@export var pieceHolder: Control
@export var trashButton: ScaleProceduralButton
@export var pauseButton: ScaleProceduralButton
@export var pauseMenu: Control
@export var gameEndMenu: Control
@export var gameEndMenuTitle: Label
@export var gameEndMenuPiece1: TextureRect
@export var gameEndMenuPlayAgainButton: ScaleProceduralButton
@export var gameEndMenuCopyReplayButton: ScaleProceduralButton
@export var gameEndMenuCopyReplayCheckmark: TextureRect
@export var gameEndMenuSettingsButton: ScaleProceduralButton
@export var gameEndMenuMainMenuButton: ScaleProceduralButton
@export var screenForMenu: ColorRect

@onready var states: Array[BoardState] = [BoardState.newDefaultStartingState(BoardState.StartSettings.new(BoardState.StartSettings.AssistMode.MOVE_ARROWS, true, 3000))]

func getScaledRectSize() -> float:
	return board.get_rect().size.x

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
		if cs.piece == null:
			continue
		if (gamePosToBoardPos(Vector2(mousePos)) - cs.piece.pos).length_squared() <= Piece.hitRadius ** 2:
			return cs.piece
	return null

func isMouseInCancelPosition(mousePosBoard_: Vector2i) -> bool:
	if (mousePosBoard_.x < -dragBorder.x or mousePosBoard_.y < -dragBorder.y or 
		mousePosBoard_.x > Piece.boardSize + dragBorder.x or mousePosBoard_.y > Piece.boardSize + dragBorder.y):
		return true
	if trashButton.buttonImprover.buttonIsHovered:
		return true
	return false

func getTimeSecs() -> float:
	return float(Time.get_ticks_msec()) / 1000.

@onready var whiteTimer: CustomTimer = CustomTimer.new(states[0].startSettings.startingTime, float(Time.get_ticks_msec()) / 1000., true, false)
@onready var blackTimer: CustomTimer = CustomTimer.new(states[0].startSettings.startingTime, float(Time.get_ticks_msec()) / 1000., true, true)
var mousePosGame: Vector2i
var mousePosBoard: Vector2i
var pieceHovering: Piece = null #a reference to the piece in the previous state
var pieceDragging: Piece = null #a reference to the piece in the previous state
var dragOffset: Vector2i = Vector2i(0, 0)
var dragPos: Vector2i = Vector2i(0, 0)
var isPiecePlaced: bool = false
var attemptedNextState: BoardState = null
const dragBorder: Vector2i = Vector2i(Piece.squareSize, Piece.squareSize)
func _process(_delta):
	determineInfoFromMouse()
	
	if pieceDragging != null:
		trashButton.enable()
		var move: Move = getMoveBeingMade()
		cancelOrContinueMove(move)
	else:
		trashButton.disable()

	updateTimer()
	checkForPause()
	checkForGameEnd()
	if gameEndMenu.visible:
		checkForActionsOnGameEndMenu()

func determineInfoFromMouse():
	#determine hovered piece
	mousePosGame = get_viewport().get_mouse_position()
	mousePosBoard = gamePosToBoardPos(mousePosGame)
	pieceHovering = getHoveredPiece(mousePosGame)
	if pieceHovering != null and pieceHovering.color != states[-1].turnToMove:
		pieceHovering = null
	
	#determine piece being dragged
	if pieceHovering != null and pieceDragging == null && Input.is_action_just_pressed("lmb"):
		pieceDragging = pieceHovering
		dragOffset = pieceDragging.pos - mousePosBoard
		isPiecePlaced = false

func getMoveBeingMade() -> Move:
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
	return move

func cancelOrContinueMove(move: Move):
	if isMouseInCancelPosition(mousePosBoard):
		attemptedNextState = null
		if Input.is_action_just_pressed("lmb") or Input.is_action_just_released("lmb"):
			pieceDragging = null
	else:
		attemptedNextState = states[-1].makeMove(move)
		if Input.is_action_just_released("lmb"):
			isPiecePlaced = true
		
		if Input.is_action_just_pressed("lmb") and isPiecePlaced:
			#this check is probably not necessary
			if attemptedNextState.result in [BoardState.StateResult.VALID, BoardState.StateResult.WIN_BLACK, BoardState.StateResult.WIN_WHITE]:
				states.append(attemptedNextState)
				if states[-1].turnToMove == Piece.PieceColor.WHITE:
					whiteTimer.unpause(getTimeSecs())
					blackTimer.pause()
				else:
					blackTimer.unpause(getTimeSecs())
					whiteTimer.pause()
			attemptedNextState = null
			pieceDragging = null

func updateTimer():
	if states[-1].turnToMove == Piece.PieceColor.WHITE:
		whiteTimer.updateTime(getTimeSecs())
		states[-1].updateTimer(whiteTimer.timeRemaining)
	else:
		blackTimer.updateTime(getTimeSecs())
		states[-1].updateTimer(blackTimer.timeRemaining)

func checkForPause():
	if pauseButton.buttonImprover.buttonUnpressedLastFrame:
		pauseMenu.visible = true
		screenForMenu.color.v = 0.5
		screenForMenu.color.a = 0.5

func checkForGameEnd():
	var showMenu: bool = false
	if states[-1].result == BoardState.StateResult.WIN_WHITE:
		gameEndMenuTitle.text = "White Wins!"
		(gameEndMenuPiece1.material as ShaderMaterial).set_shader_parameter("frame", BoardRenderer.getPieceFrame(Piece.PieceColor.WHITE, Piece.PieceType.KING))
		screenForMenu.color.v = 1.
		showMenu = true
	elif states[-1].result == BoardState.StateResult.WIN_BLACK:
		gameEndMenuTitle.text = "Black Wins!"
		(gameEndMenuPiece1.material as ShaderMaterial).set_shader_parameter("frame", BoardRenderer.getPieceFrame(Piece.PieceColor.BLACK, Piece.PieceType.KING))
		screenForMenu.color.v = 0.
		showMenu = true
	if showMenu:
		gameEndMenu.visible = true
		screenForMenu.color.a = 0.5

func checkForActionsOnGameEndMenu():
	if gameEndMenuPlayAgainButton.buttonImprover.buttonUnpressedLastFrame:
		get_tree().reload_current_scene()
	elif gameEndMenuCopyReplayButton.buttonImprover.buttonUnpressedLastFrame:
		gameEndMenuCopyReplayCheckmark.visible = true #doesn't do anything for now
		DisplayServer.clipboard_set("PLACEHOLDER")
