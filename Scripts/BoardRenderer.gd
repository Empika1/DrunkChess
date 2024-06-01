extends Node
class_name BoardRenderer

@export var board: TextureRect
@export var pieceHolder: Control
@export var blackTimer: Label
@export var whiteTimer: Label
@export var blackCaptures: HBoxContainer
@export var whiteCaptures: HBoxContainer
@export var disableCapturesButton: BorderScaleButton

@export var lines: TextureRect
@export var circles: TextureRect
@export var circleArcs: TextureRect
@export var arrows: TextureRect
@export var gameManager: GameManager

var pieceScene: PackedScene = load("res://Prefabs/DraggablePiece.tscn")

const shadowRealm: Vector2 = Vector2(9999999, 9999999)
var usedPiecePool: Array[DraggablePiece]
var freePiecePool: Array[DraggablePiece]

var whiteCapturesContainers: Array[AspectRatioContainer]
var blackCapturesContainers: Array[AspectRatioContainer]

func addPieceToFreePool(piece) -> void:
	var sprite: DraggablePiece = pieceScene.instantiate()
	sprite.material = sprite.material.duplicate()
	freePiecePool.append(sprite)
	pieceHolder.add_child(sprite)
	sprite.init(piece)

func _ready() -> void:
	for piece in gameManager.states[-1].pieces:
		addPieceToFreePool(piece)
		
		var container: AspectRatioContainer = AspectRatioContainer.new()
		container.stretch_mode = AspectRatioContainer.STRETCH_HEIGHT_CONTROLS_WIDTH
		if piece.color == Piece.PieceColor.WHITE:
			whiteCaptures.add_child(container)
			whiteCapturesContainers.append(container)
		else:
			blackCaptures.add_child(container)
			blackCapturesContainers.append(container)
	
	for i in range(5):
		var container: AspectRatioContainer = AspectRatioContainer.new()
		container.stretch_mode = AspectRatioContainer.STRETCH_HEIGHT_CONTROLS_WIDTH
		whiteCaptures.add_child(container)
		whiteCapturesContainers.append(container)
	
	for i in range(5):
		var container: AspectRatioContainer = AspectRatioContainer.new()
		container.stretch_mode = AspectRatioContainer.STRETCH_HEIGHT_CONTROLS_WIDTH
		blackCaptures.add_child(container)
		blackCapturesContainers.append(container)

static func getPieceFrame(col: Piece.PieceColor, type: Piece.PieceType) -> int:
	return int(col) * 6 + int(type)

func formatTime(seconds_: float) -> String:
	var totalTenths: int = int(seconds_ * 10)
	var tenths: int = totalTenths
	var hours: int = tenths / 36000
	tenths %= 36000
	var minutes: int = tenths / 600
	tenths %= 600
	var seconds: int = tenths / 10
	tenths %= 10
	return ((str(hours) + ":" if hours > 0 else "") +
			(str(minutes) + ":" if minutes > 0 else "") +
			(("0" if seconds < 10 else "") + str(seconds)) +
			("." + str(tenths) if totalTenths <= 300 else ""))

var stateToRender: BoardState
func _process(_delta) -> void:
	deleteCircles(); deleteLines(); deleteArcs(); deleteArrows();
	if gameManager.attemptedNextState != null:
		stateToRender = gameManager.attemptedNextState
	else:
		stateToRender = gameManager.states[-1]

	while len(usedPiecePool) > 0:
		var sprite: DraggablePiece = usedPiecePool.pop_back()
		sprite.reparent(pieceHolder)
		freePiecePool.append(sprite)
	
	for piece in stateToRender.pieces:
		var sprite: DraggablePiece = freePiecePool.pop_back()
		usedPiecePool.append(sprite)
		
		sprite.piece = piece
		(sprite.material as ShaderMaterial).set_shader_parameter("frame", getPieceFrame(piece.color, piece.type))
		sprite.size = board.size / 8
		sprite.global_position = gameManager.boardPosToGamePos(piece.pos) - sprite.size / 2
	
	var whiteCapturedPiecesSorted: Array[Piece] = []
	var blackCapturedPiecesSorted: Array[Piece] = []
	for piece in stateToRender.capturedPieces:
		if piece.color == Piece.PieceColor.WHITE:
			whiteCapturedPiecesSorted.append(piece)
		else:
			blackCapturedPiecesSorted.append(piece)
	whiteCapturedPiecesSorted.sort_custom(Piece.sortByType)
	blackCapturedPiecesSorted.sort_custom(Piece.sortByType)
	
	var i: int = 0
	var pieceI: int = 0
	while pieceI < len(whiteCapturedPiecesSorted):
		var piece: Piece = whiteCapturedPiecesSorted[pieceI]
		var sprite: DraggablePiece = freePiecePool.pop_back()
		usedPiecePool.append(sprite)
		sprite.piece = piece
		(sprite.material as ShaderMaterial).set_shader_parameter("frame", getPieceFrame(piece.color, piece.type))
		if pieceI > 0 and piece.type != whiteCapturedPiecesSorted[pieceI - 1].type:
			whiteCapturesContainers[i].size_flags_horizontal = Control.SIZE_EXPAND_FILL
			i += 1
		sprite.reparent(whiteCapturesContainers[i])
		whiteCapturesContainers[i].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		i += 1
		pieceI += 1
	while i < len(whiteCapturesContainers):
		whiteCapturesContainers[i].size_flags_horizontal = Control.SIZE_FILL
		i += 1
	
	i = 0
	pieceI = 0
	while pieceI < len(blackCapturedPiecesSorted):
		var piece: Piece = blackCapturedPiecesSorted[pieceI]
		var sprite: DraggablePiece = freePiecePool.pop_back()
		usedPiecePool.append(sprite)
		sprite.piece = piece
		(sprite.material as ShaderMaterial).set_shader_parameter("frame", getPieceFrame(piece.color, piece.type))
		if pieceI > 0 and piece.type != blackCapturedPiecesSorted[pieceI - 1].type:
			blackCapturesContainers[i].size_flags_horizontal = Control.SIZE_EXPAND_FILL
			i += 1
		sprite.reparent(blackCapturesContainers[i])
		blackCapturesContainers[i].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		i += 1
		pieceI += 1
	while i < len(blackCapturesContainers):
		blackCapturesContainers[i].size_flags_horizontal = Control.SIZE_FILL
		i += 1
	
	for sprite in freePiecePool:
		sprite.global_position = shadowRealm
		sprite.piece = null
	
	if gameManager.attemptedNextState != null and !gameManager.isMenuVisible():
		addHitRadii(gameManager.attemptedNextState.pieces)
		addMoveIndicators(gameManager.states[-1], gameManager.pieceDragging)
		if (gameManager.attemptedNextState.previousMove.moveType == Move.MoveType.CASTLE or
		   (gameManager.attemptedNextState.previousMove.moveType == Move.MoveType.NORMAL and
			gameManager.pieceDragging.type == Piece.PieceType.KING)):
			addCastleAreas(gameManager.states[-1].castlePoints)
	elif gameManager.pieceHovering != null and !gameManager.isMenuVisible():
		addHitRadius(gameManager.pieceHovering)
	
	if disableCapturesButton.buttonComponent.state.toggleState == 0:
		addCaptureArrows(stateToRender)
	
	if gameManager.states[0].startSettings.isTimed:
		whiteTimer.text = formatTime(gameManager.states[-1].whiteTime)
		blackTimer.text = formatTime(gameManager.states[-1].blackTime)
	else:
		whiteTimer.text = "XX:XX"
		blackTimer.text = "XX:XX"
	
	setCircles(); setLines(); setArcs(); setArrows();

var lineStarts: PackedVector2Array
var lineEnds: PackedVector2Array
var lineColorsrg: PackedVector2Array
var lineColorsba: PackedVector2Array
var lineThicknesses: PackedFloat32Array
func setLines() -> void:
	var mat = lines.material as ShaderMaterial
	mat.set_shader_parameter("lineStarts", lineStarts)
	mat.set_shader_parameter("lineEnds", lineEnds)
	mat.set_shader_parameter("lineColorsrg", lineColorsrg)
	mat.set_shader_parameter("lineColorsba", lineColorsba)
	mat.set_shader_parameter("lineThicknesses", lineThicknesses)
func deleteLines() -> void:
	lineStarts = PackedVector2Array(); lineEnds = PackedVector2Array(); lineColorsrg = PackedVector2Array()
	lineColorsba = PackedVector2Array(); lineThicknesses = PackedFloat32Array()
	setLines()

var circleCenters: PackedVector2Array
var circleRadii: PackedFloat32Array
var circleColorsrg: PackedVector2Array
var circleColorsba: PackedVector2Array
func setCircles() -> void:
	var mat = circles.material as ShaderMaterial
	mat.set_shader_parameter("circleCenters", circleCenters)
	mat.set_shader_parameter("circleRadii", circleRadii)
	mat.set_shader_parameter("circleColorsrg", circleColorsrg)
	mat.set_shader_parameter("circleColorsba", circleColorsba)
func deleteCircles() -> void:
	circleCenters = PackedVector2Array(); circleRadii = PackedFloat32Array()
	circleColorsrg = PackedVector2Array(); circleColorsba = PackedVector2Array()
	setCircles()

var arcCenters: PackedVector2Array
var arcRadii: PackedFloat32Array
var arcThicknesses: PackedFloat32Array
var arcColorsrg: PackedVector2Array
var arcColorsba: PackedVector2Array
var arcEndIndices: PackedInt32Array
var arcStarts: PackedVector2Array
var arcEnds: PackedVector2Array
func setArcs() -> void:
	var mat = circleArcs.material as ShaderMaterial
	mat.set_shader_parameter("circleCenters", arcCenters)
	mat.set_shader_parameter("circleRadii", arcRadii)
	mat.set_shader_parameter("circleThicknesses", arcThicknesses)
	mat.set_shader_parameter("circleColorsrg", arcColorsrg)
	mat.set_shader_parameter("circleColorsba", arcColorsba)
	mat.set_shader_parameter("arcEndIndices", arcEndIndices)
	mat.set_shader_parameter("arcStarts", arcStarts)
	mat.set_shader_parameter("arcEnds", arcEnds)
func deleteArcs() -> void:
	arcCenters = PackedVector2Array(); arcRadii = PackedFloat32Array(); arcThicknesses = PackedFloat32Array()
	arcColorsrg = PackedVector2Array(); arcColorsba = PackedVector2Array(); arcEndIndices = PackedInt32Array()
	arcStarts = PackedVector2Array(); arcEnds = PackedVector2Array()
	setArcs()

@export var hitRadiusColor: Color
func addHitRadii(pieces: Array[Piece]) -> void:
	for piece in pieces:
		addHitRadius(piece)
func addHitRadius(piece: Piece) -> void:
	circleCenters.append(Vector2(piece.pos) / Piece.boardSize)
	circleRadii.append(float(piece.hitRadius) / Piece.boardSize)
	circleColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
	circleColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

@export var thickness: float
func addMoveIndicators(state: BoardState, pieceDragging: Piece) -> void:
	match gameManager.pieceDragging.type:
		Piece.PieceType.PAWN:
			addPawnLines(state, pieceDragging)
		Piece.PieceType.KNIGHT:
			addKnightArcs(state, pieceDragging)
		Piece.PieceType.BISHOP:
			addBishopLines(state, pieceDragging)
		Piece.PieceType.ROOK:
			addRookLines(state, pieceDragging)
		Piece.PieceType.QUEEN:
			addQueenLines(state, pieceDragging)
		_:
			addKingLines(state, pieceDragging)

func addPawnLines(state: BoardState, pieceDragging: Piece) -> void:
	var pawnPoints: PieceLogic.PawnMovePoints = state.movePoints[state.findPieceIndex(pieceDragging)] as PieceLogic.PawnMovePoints
	lineStarts.append(Vector2(pawnPoints.verticalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(pawnPoints.verticalUpperBound) / Piece.boardSize)
	lineStarts.append(Vector2(pawnPoints.positiveDiagonalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(pawnPoints.positiveDiagonalUpperBound) / Piece.boardSize)
	lineStarts.append(Vector2(pawnPoints.negativeDiagonalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(pawnPoints.negativeDiagonalUpperBound) / Piece.boardSize)
	for i in range(3):
		lineThicknesses.append(thickness)
		lineColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		lineColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

func addKnightArcs(state: BoardState, pieceDragging: Piece) -> void:
	var knightPoints: PieceLogic.KnightMovePoints = state.movePoints[state.findPieceIndex(pieceDragging)] as PieceLogic.KnightMovePoints
	arcCenters.append(Vector2(gameManager.pieceDragging.pos) / Piece.boardSize)
	arcRadii.append(float(Piece.knightMoveRadius) / Piece.boardSize)
	arcColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
	arcColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))
	arcThicknesses.append(thickness)
	arcEndIndices.append(knightPoints.arcEnds.size())
	for i in range(knightPoints.arcStarts.size()):
		arcStarts.append(Vector2(knightPoints.arcStarts[i]) / Piece.boardSize)
		arcEnds.append(Vector2(knightPoints.arcEnds[i]) / Piece.boardSize)
		
func addBishopLines(state: BoardState, pieceDragging: Piece) -> void:
	var bishopPoints: PieceLogic.BishopMovePoints = state.movePoints[state.findPieceIndex(pieceDragging)] as PieceLogic.BishopMovePoints
	lineStarts.append(Vector2(bishopPoints.positiveDiagonalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(bishopPoints.positiveDiagonalUpperBound) / Piece.boardSize)
	lineStarts.append(Vector2(bishopPoints.negativeDiagonalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(bishopPoints.negativeDiagonalUpperBound) / Piece.boardSize)
	for i in range(2):
		lineThicknesses.append(thickness)
		lineColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		lineColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

func addRookLines(state: BoardState, pieceDragging: Piece) -> void:
	var rookPoints: PieceLogic.RookMovePoints = state.movePoints[state.findPieceIndex(pieceDragging)] as PieceLogic.RookMovePoints
	lineStarts.append(Vector2(rookPoints.horizontalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(rookPoints.horizontalUpperBound) / Piece.boardSize)
	lineStarts.append(Vector2(rookPoints.verticalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(rookPoints.verticalUpperBound) / Piece.boardSize)
	for i in range(2):
		lineThicknesses.append(thickness)
		lineColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		lineColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

func addQueenLines(state: BoardState, pieceDragging: Piece) -> void:
	var queenPoints: PieceLogic.QueenMovePoints = state.movePoints[state.findPieceIndex(pieceDragging)] as PieceLogic.QueenMovePoints
	lineStarts.append(Vector2(queenPoints.positiveDiagonalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(queenPoints.positiveDiagonalUpperBound) / Piece.boardSize)
	lineStarts.append(Vector2(queenPoints.negativeDiagonalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(queenPoints.negativeDiagonalUpperBound) / Piece.boardSize)
	lineStarts.append(Vector2(queenPoints.horizontalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(queenPoints.horizontalUpperBound) / Piece.boardSize)
	lineStarts.append(Vector2(queenPoints.verticalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(queenPoints.verticalUpperBound) / Piece.boardSize)
	for i in range(4):
		lineThicknesses.append(thickness)
		lineColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		lineColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

func addKingLines(state: BoardState, pieceDragging: Piece) -> void:
	var kingPoints: PieceLogic.KingMovePoints = state.movePoints[state.findPieceIndex(pieceDragging)] as PieceLogic.KingMovePoints
	lineStarts.append(Vector2(kingPoints.positiveDiagonalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(kingPoints.positiveDiagonalUpperBound) / Piece.boardSize)
	lineStarts.append(Vector2(kingPoints.negativeDiagonalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(kingPoints.negativeDiagonalUpperBound) / Piece.boardSize)
	lineStarts.append(Vector2(kingPoints.horizontalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(kingPoints.horizontalUpperBound) / Piece.boardSize)
	lineStarts.append(Vector2(kingPoints.verticalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(kingPoints.verticalUpperBound) / Piece.boardSize)
	for i in range(4):
		lineThicknesses.append(thickness)
		lineColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		lineColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

static var castleRadius: int = Piece.boardSize / 16
func addCastleArea(center: Vector2i) -> void:
	circleCenters.append(Vector2(center) / Vector2(Piece.boardSize, Piece.boardSize))
	circleRadii.append(float(castleRadius) / float(Piece.boardSize))
	circleColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
	circleColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))
func addCastleAreas(castlePoints: PieceLogic.CastlePoints):
	if castlePoints.canCastleLeft:
		addCastleArea(castlePoints.kingPointLeft)
	if castlePoints.canCastleRight:
		addCastleArea(castlePoints.kingPointRight)

var arrowStarts: PackedVector2Array
var arrowEnds: PackedVector2Array
var arrowColorsrg: PackedVector2Array
var arrowColorsba: PackedVector2Array
var arrowThicknesses: PackedFloat32Array
var arrowDistortPoints: PackedVector2Array
func setArrows() -> void:
	var mat = arrows.material as ShaderMaterial
	mat.set_shader_parameter("arrowStarts", arrowStarts)
	mat.set_shader_parameter("arrowEnds", arrowEnds)
	mat.set_shader_parameter("arrowColorsrg", arrowColorsrg)
	mat.set_shader_parameter("arrowColorsba", arrowColorsba)
	mat.set_shader_parameter("arrowThicknesses", arrowThicknesses)
	mat.set_shader_parameter("arrowDistortPoints", arrowDistortPoints)
func deleteArrows() -> void:
	arrowStarts = PackedVector2Array(); arrowEnds = PackedVector2Array(); arrowColorsrg = PackedVector2Array()
	arrowColorsba = PackedVector2Array(); arrowThicknesses = PackedFloat32Array(); arrowDistortPoints = PackedVector2Array()
	setLines()

@export var whiteCapturerArrowColor: Color
@export var blackCapturerArrowColor: Color
@export var arrowThickness: float
func addCaptureArrows(state: BoardState) -> void:
	for i in range(len(state.pieces)):
		var capturer: Piece = state.pieces[i]
		var piecesCanCapture: Array[Piece] = state.piecesCanCapture[i]
		for capturee: Piece in piecesCanCapture:
			arrowStarts.append(Vector2(capturer.pos) / Piece.boardSize)
			arrowEnds.append(Vector2(capturee.pos) / Piece.boardSize)
			if capturer.color == Piece.PieceColor.WHITE:
				arrowColorsrg.append(Vector2(whiteCapturerArrowColor.r, whiteCapturerArrowColor.g))
				arrowColorsba.append(Vector2(whiteCapturerArrowColor.b, whiteCapturerArrowColor.a))
			else:
				arrowColorsrg.append(Vector2(blackCapturerArrowColor.r, blackCapturerArrowColor.g))
				arrowColorsba.append(Vector2(blackCapturerArrowColor.b, blackCapturerArrowColor.a))
			arrowThicknesses.append(arrowThickness)
			var arrowMidpoint: Vector2 = (arrowStarts[-1] + arrowEnds[-1]) / 2
			const lengthMultiplier: float = 0.1
			var arrowDisplace: Vector2 = arrowEnds[-1] - arrowStarts[-1]
			arrowDisplace = Vector2(arrowDisplace.y, -arrowDisplace.x)
			arrowDisplace *= lengthMultiplier
			arrowDistortPoints.append(arrowMidpoint + arrowDisplace)
