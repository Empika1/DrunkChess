extends Node
class_name GameManager

@export var board: TextureRect
@export var pieceHolder: Control
@export var trashButton: BorderScaleButton
@export var pauseButton: BorderScaleButton
@export var drawButton: BorderScaleButton
@export var disableCapturesButton: BorderScaleButton
@export var pauseMenu: Control
@export var pauseMenuResumeButton: BorderScaleButton
@export var pauseMenuSettingsButton: BorderScaleButton
@export var pauseMenuMainMenuButton: BorderScaleButton
@export var drawMenu: Control
@export var drawMenuAcceptButton: BorderScaleButton
@export var drawMenuRejectButton: BorderScaleButton
@export var gameEndMenu: Control
@export var gameEndMenuTitle: Label
@export var gameEndMenuPiece1: TextureRect
@export var gameEndMenuPiece2: TextureRect
@export var gameEndMenuPlayAgainButton: BorderScaleButton
@export var gameEndMenuCopyReplayButton: BorderScaleButton
@export var gameEndMenuCopyReplayCheckmark: TextureRect
@export var gameEndMenuSettingsButton: BorderScaleButton
@export var gameEndMenuMainMenuButton: BorderScaleButton
@export var screenForMenu: ColorRect

@onready var states: Array[BoardState] = [BoardState.newDefaultStartingState(BoardState.StartSettings.new(BoardState.StartSettings.AssistMode.MOVE_ARROWS, true, 3000))]
#@onready var states: Array[BoardState] = [Replay.replayToState(Replay.stringToReplay("v1H4sIAAAAAAAACpNhYGBgAmIZIOaC0gpQmgWI2YCYQQCCQeqYoeoZoZgBm9oPqGoZ8Kk1QKghaO4FVLU4zTVAuJeRkLkGCPcyEmMuse41IMG9AQj3wjBOcwMQ7mUixlxi3RtAgnsLEO5lIWRuAcK9LMSYS6x7C0hw7wSEe1kJmTsB4V5WYswl1r0TIBibexnR1W5gID49bGAgPj1sIMG9ILXEhu8FBuLz2wUG4vPbBRLce4EE935gIL48+8BAfHn2gQT3fiDsXmQzmJDER8vp0XJ6tJxmoF05Tax7R8vp0XIaTRxGMyDJMyOZD2IzNFi7MsH5jAyVL9UMOXKWOyDLwfSyIZlJSjpFb3Owke0mRgbLLSfK6nKXOyC7gwNKc6L5nY8BKd8XIOwG0f+BAEaDzA3onZ53KRO3HehmC5Npdhif7qa7WfjNFkQOMwJmt4vdPPc9nXizhZDdHUC82YobijIuZpDg7gn4zTbkWCNzK5V4s1HcbUC82fy6m+bmp5Hg7g34zd5TMlmiJYmw2bBySgjZbLT6jxSzATHEXQgcDwAA"))]

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
	if trashButton.buttonComponent.state.isHoveredIgnoreDisable:
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

var copiedStateString: String = ""
func _process(_delta):
	if !isMenuVisible():
		determineInfoFromMouse()
		
		if pieceDragging != null:
			trashButton.enable()
			var move: Move = getMoveBeingMade()
			cancelOrContinueMove(move)
		else:
			trashButton.disable()

	updateTimer()
	checkForGameEnd()

func _ready():
	pauseButton.buttonComponent.stateUpdated.connect(pause)
	drawButton.buttonComponent.stateUpdated.connect(offerDraw)
	pauseMenuResumeButton.buttonComponent.stateUpdated.connect(unpause)
	pauseMenuMainMenuButton.buttonComponent.stateUpdated.connect(goToMainMenu)
	drawMenuAcceptButton.buttonComponent.stateUpdated.connect(acceptDraw)
	drawMenuRejectButton.buttonComponent.stateUpdated.connect(rejectDraw)
	gameEndMenuPlayAgainButton.buttonComponent.stateUpdated.connect(playAgain)
	gameEndMenuCopyReplayButton.buttonComponent.stateUpdated.connect(copyReplay)
	gameEndMenuMainMenuButton.buttonComponent.stateUpdated.connect(goToMainMenu)

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
	if pieceDragging.type == Piece.PieceType.KING:
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

func isMenuVisible():
	return pauseMenu.visible or drawMenu.visible or gameEndMenu.visible

func hideAllMenuItems():
	pauseMenu.visible = false
	drawMenu.visible = false
	gameEndMenu.visible = false
	screenForMenu.color.a = 0.

var pauseButtonWasEnabled: bool
var disableCapturesButtonWasEnabled: bool
var trashButtonWasEnabled: bool
var drawButtonWasEnabled: bool
func disableAllButtons():
	pauseButtonWasEnabled = not pauseButton.buttonComponent.state.isDisabled
	disableCapturesButtonWasEnabled = not disableCapturesButton.buttonComponent.state.isDisabled
	trashButtonWasEnabled = not trashButton.buttonComponent.state.isDisabled
	drawButtonWasEnabled = not drawButton.buttonComponent.state.isDisabled
	pauseButton.disable()
	disableCapturesButton.disable()
	trashButton.disable()
	drawButton.disable()

func undisableAllButtons():
	if pauseButtonWasEnabled: pauseButton.enable()
	if disableCapturesButtonWasEnabled: disableCapturesButton.enable()
	if trashButtonWasEnabled: trashButton.enable()
	if drawButtonWasEnabled: drawButton.enable()

func pauseTimer():
	whiteTimer.pause()
	blackTimer.pause()

func unpauseTimer():
	if states[-1].turnToMove == Piece.PieceColor.WHITE:
		whiteTimer.unpause(getTimeSecs())
	else:
		blackTimer.unpause(getTimeSecs())

func pause(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		hideAllMenuItems()
		disableAllButtons()
		pauseTimer()
		
		pauseMenu.visible = true
		screenForMenu.color.v = 0.5
		screenForMenu.color.a = 0.5

func offerDraw(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		hideAllMenuItems()
		disableAllButtons()
		pauseTimer()
		
		drawMenu.visible = true
		screenForMenu.color.v = 0.5
		screenForMenu.color.a = 0.5
		
		states[-1].offerDraw()

func checkForGameEnd():
	if gameEndMenu.visible:
		return
	var showMenu: bool = false
	if states[-1].result == BoardState.StateResult.WIN_WHITE:
		gameEndMenuTitle.text = "White Wins!"
		(gameEndMenuPiece1.material as ShaderMaterial).set_shader_parameter("frame", BoardRenderer.getPieceFrame(Piece.PieceColor.WHITE, Piece.PieceType.KING))
		(gameEndMenuPiece2.material as ShaderMaterial).set_shader_parameter("frame", BoardRenderer.getPieceFrame(Piece.PieceColor.WHITE, Piece.PieceType.KING))
		screenForMenu.color.v = 1.
		showMenu = true
	elif states[-1].result == BoardState.StateResult.WIN_BLACK:
		gameEndMenuTitle.text = "Black Wins!"
		(gameEndMenuPiece1.material as ShaderMaterial).set_shader_parameter("frame", BoardRenderer.getPieceFrame(Piece.PieceColor.BLACK, Piece.PieceType.KING))
		(gameEndMenuPiece2.material as ShaderMaterial).set_shader_parameter("frame", BoardRenderer.getPieceFrame(Piece.PieceColor.BLACK, Piece.PieceType.KING))
		screenForMenu.color.v = 0.
		showMenu = true
	elif states[-1].result == BoardState.StateResult.DRAW:
		gameEndMenuTitle.text = "Draw!"
		(gameEndMenuPiece1.material as ShaderMaterial).set_shader_parameter("frame", BoardRenderer.getPieceFrame(Piece.PieceColor.WHITE, Piece.PieceType.KING))
		(gameEndMenuPiece2.material as ShaderMaterial).set_shader_parameter("frame", BoardRenderer.getPieceFrame(Piece.PieceColor.BLACK, Piece.PieceType.KING))
		screenForMenu.color.v = 0.5
		showMenu = true
	if showMenu:
		hideAllMenuItems()
		disableAllButtons()
		pauseTimer()
		
		gameEndMenu.visible = true
		screenForMenu.color.a = 0.5

func unpause(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		undisableAllButtons()
		hideAllMenuItems()
		unpauseTimer()

func goToMainMenu(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func acceptDraw(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		states[-1].confirmDraw()

func rejectDraw(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		states[-1].rejectDraw()
		
		undisableAllButtons()
		hideAllMenuItems()
		unpauseTimer()

func playAgain(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		get_tree().reload_current_scene()

func copyReplay(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		#print(Replay.validBoardStateToBitArray(states[-1]).toBase64(3))
		DisplayServer.clipboard_set(Replay.validBoardStateToBitArray(states[-1]).toBase64(3))
		gameEndMenuCopyReplayCheckmark.visible = true
