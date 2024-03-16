extends Sprite2D
class_name BoardRenderer

@export var pieceHolder: Node2D
@export var lines: Sprite2D
@export var circles: Sprite2D
@export var circleArcs: Sprite2D
@export var arrows: Sprite2D

@onready var states: Array[BoardState] = [BoardState.newDefaultStartingState()]

const shadowRealm: Vector2 = Vector2(9999999, 9999999)
var pieceScene: PackedScene = preload("res://Prefabs/DraggablePiece.tscn")
var usedPiecePool: Dictionary
var freePiecePool: Dictionary

func addPieceToFreePool(piece) -> DraggablePiece:
	var sprite: DraggablePiece = pieceScene.instantiate()
	freePiecePool[piece.color][piece.type].append(sprite)
	pieceHolder.add_child(sprite)
	sprite.init(self, piece)
	return sprite

func _ready() -> void:	
	usedPiecePool[Piece.PieceColor.WHITE] = Dictionary()
	usedPiecePool[Piece.PieceColor.BLACK] = Dictionary()
	freePiecePool[Piece.PieceColor.WHITE] = Dictionary()
	freePiecePool[Piece.PieceColor.BLACK] = Dictionary()
	for type in Piece.PieceType.values():
		usedPiecePool[Piece.PieceColor.WHITE][type] = []
		usedPiecePool[Piece.PieceColor.BLACK][type] = []
		freePiecePool[Piece.PieceColor.WHITE][type] = []
		freePiecePool[Piece.PieceColor.BLACK][type] = []
	for piece in states[-1].pieces:
		addPieceToFreePool(piece)
	
func _process(_delta) -> void:
	render()

@export var wp: Texture2D
@export var wn: Texture2D
@export var wb: Texture2D
@export var wr: Texture2D
@export var wq: Texture2D
@export var wk: Texture2D

@export var bp: Texture2D
@export var bn: Texture2D
@export var bb: Texture2D
@export var br: Texture2D
@export var bq: Texture2D
@export var bk: Texture2D

func getPieceTexture(pieceType: Piece.PieceType, pieceColor: Piece.PieceColor) -> Texture2D:
	match pieceColor:
		Piece.PieceColor.WHITE:
			match pieceType:
				Piece.PieceType.PAWN:
					return wp
				Piece.PieceType.KNIGHT:
					return wn
				Piece.PieceType.BISHOP:
					return wb
				Piece.PieceType.ROOK:
					return wr
				Piece.PieceType.QUEEN:
					return wq
				_:
					return wk
		_:
			match pieceType:
				Piece.PieceType.PAWN:
					return bp
				Piece.PieceType.KNIGHT:
					return bn
				Piece.PieceType.BISHOP:
					return bb
				Piece.PieceType.ROOK:
					return br
				Piece.PieceType.QUEEN:
					return bq
				_:
					return bk

func getScaledRectSize():
	return get_rect().size * global_scale

func boardLengthToGameLength(boardLength: Vector2i) -> Vector2:
	return Vector2(boardLength) / Vector2(Piece.boardSize, Piece.boardSize) * getScaledRectSize()

func boardPosToGamePos(boardPos: Vector2i) -> Vector2:
	return boardLengthToGameLength(boardPos) + global_position

func gameLengthToBoardLength(gameLength: Vector2) -> Vector2i:
	return Vector2i(gameLength * Vector2(Piece.boardSize, Piece.boardSize) / getScaledRectSize())

func gamePosToBoardPos(gamePos: Vector2) -> Vector2i:
	return gameLengthToBoardLength(gamePos - global_position)

func getHoveredPiece(mousePos: Vector2i) -> Piece:
	for c in pieceHolder.get_children():
		var cs = c as DraggablePiece
		var distanceSquared = (cs.global_position.x - mousePos.x) ** 2 + (cs.global_position.y - mousePos.y) ** 2
		if distanceSquared < (float(c.piece.hitRadius) / Piece.boardSize * getScaledRectSize().x) ** 2:
			return cs.piece
	return null

var pieceDraggingPreviousState: Piece
var pieceDraggingNextState: Piece
var dragOffset: Vector2i
var attemptedNextState: BoardState
var stateToRender: BoardState
func render() -> void:
	deleteCircles(); deleteLines(); deleteArcs(); deleteArrows();
	var mousePos: Vector2i = get_viewport().get_mouse_position()
	if pieceDraggingPreviousState == null && Input.is_action_just_pressed("lmb"):
		pieceDraggingPreviousState = getHoveredPiece(mousePos)
		if pieceDraggingPreviousState != null:
			dragOffset = boardPosToGamePos(pieceDraggingPreviousState.pos) - Vector2(mousePos)
	
	if pieceDraggingPreviousState != null:
		var move: Move = null
		
		var castlePieces: PieceLogic.CastlePieces = states[-1].castlePieces
		var castlePoints: PieceLogic.CastlePoints = states[-1].castlePoints
		if castlePoints.canCastleLeft:
			addCastleArea(castlePoints.kingPointLeft)
			if (gamePosToBoardPos(mousePos) - castlePoints.kingPointLeft).length_squared() < castleRadius ** 2:
				move = Move.newCastle(castlePieces.king, castlePieces.leftRook)
		if castlePoints.canCastleRight:
			addCastleArea(castlePoints.kingPointRight)
			if (gamePosToBoardPos(mousePos) - castlePoints.kingPointRight).length_squared() < castleRadius ** 2:
				move = Move.newCastle(castlePieces.king, castlePieces.rightRook)
		
		if move == null:
			var movePos: Vector2i = PieceLogic.closestPosCanMoveTo(pieceDraggingPreviousState, states[-1].pieces, gamePosToBoardPos(mousePos + dragOffset), 
				states[-1].movePoints[states[-1].findPieceIndex(pieceDraggingPreviousState)])
			
			if pieceDraggingPreviousState.type == Piece.PieceType.PAWN and Piece.isPromotionPosition(movePos, states[-1].turnToMove):
				move = Move.newPromotion(pieceDraggingPreviousState, movePos, Piece.PieceType.QUEEN)
			else:
				move = Move.newNormal(pieceDraggingPreviousState, movePos)
			pieceDraggingNextState = pieceDraggingPreviousState.duplicate()
			pieceDraggingNextState.pos = movePos

		attemptedNextState = states[-1].makeMove(move)
		
		if Input.is_action_just_released("lmb"):
			if attemptedNextState.result in [BoardState.StateResult.VALID, BoardState.StateResult.WIN_BLACK, BoardState.StateResult.WIN_WHITE]:
				states.append(attemptedNextState)
			attemptedNextState = null
			pieceDraggingPreviousState = null
			pieceDraggingNextState = null
			dragOffset = Vector2i.ZERO
	
	if states[-1].result in [BoardState.StateResult.WIN_BLACK, BoardState.StateResult.WIN_WHITE]:
		print("hhhhhhhhhhhhhhhhhhhhhhhhhhhhh")

	if attemptedNextState != null:
		stateToRender = attemptedNextState
	else:
		stateToRender = states[-1]

	for col in [Piece.PieceColor.BLACK, Piece.PieceColor.WHITE]:
		for key in usedPiecePool[col]:
			var arr: Array = usedPiecePool[col][key]
			while arr.size() > 0:
				var piece = arr.pop_back()
				freePiecePool[col][key].append(piece)
	for piece in stateToRender.pieces:
		var sprite: DraggablePiece = freePiecePool[piece.color][piece.type].pop_back()
		if sprite == null:
			sprite = addPieceToFreePool(piece)
			sprite = freePiecePool[piece.color][piece.type].pop_back()
			
		sprite.piece = piece
		usedPiecePool[piece.color][piece.type].append(sprite)
		sprite.global_position = boardPosToGamePos(piece.pos)
		sprite.global_scale = global_scale
	
	if pieceDraggingPreviousState != null:
		addHitRadii(stateToRender.pieces)
		addMoveIndicators(states[-1])
	addCaptureArrows(stateToRender)
	
	for col in [Piece.PieceColor.BLACK, Piece.PieceColor.WHITE]:
		for key in freePiecePool[col]:
			var arr: Array = freePiecePool[col][key]
			for piece in arr:
				piece.global_position = shadowRealm
	
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
		circleCenters.append(Vector2(piece.pos) / Piece.boardSize)
		circleRadii.append(float(piece.hitRadius) / Piece.boardSize)
		circleColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		circleColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

@export var thickness: float
func addMoveIndicators(state: BoardState) -> void:
	match pieceDraggingPreviousState.type:
		Piece.PieceType.PAWN:
			addPawnLines(state)
		Piece.PieceType.KNIGHT:
			addKnightArcs(state)
		Piece.PieceType.BISHOP:
			addBishopLines(state)
		Piece.PieceType.ROOK:
			addRookLines(state)
		Piece.PieceType.QUEEN:
			addQueenLines(state)
		_:
			addKingLines(state)

func addPawnLines(state: BoardState) -> void:
	var pawnPoints: PieceLogic.PawnMovePoints = state.movePoints[state.findPieceIndex(pieceDraggingPreviousState)] as PieceLogic.PawnMovePoints
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

func addKnightArcs(state: BoardState) -> void:
	var knightPoints: PieceLogic.KnightMovePoints = state.movePoints[state.findPieceIndex(pieceDraggingPreviousState)] as PieceLogic.KnightMovePoints
	arcCenters.append(Vector2(pieceDraggingPreviousState.pos) / Piece.boardSize)
	arcRadii.append(float(pieceDraggingPreviousState.knightMoveRadius) / Piece.boardSize)
	arcColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
	arcColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))
	arcThicknesses.append(thickness)
	arcEndIndices.append(knightPoints.arcEnds.size())
	for i in range(knightPoints.arcStarts.size()):
		arcStarts.append(Vector2(knightPoints.arcStarts[i]) / Piece.boardSize)
		arcEnds.append(Vector2(knightPoints.arcEnds[i]) / Piece.boardSize)
		
func addBishopLines(state: BoardState) -> void:
	var bishopPoints: PieceLogic.BishopMovePoints = state.movePoints[state.findPieceIndex(pieceDraggingPreviousState)] as PieceLogic.BishopMovePoints
	lineStarts.append(Vector2(bishopPoints.positiveDiagonalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(bishopPoints.positiveDiagonalUpperBound) / Piece.boardSize)
	lineStarts.append(Vector2(bishopPoints.negativeDiagonalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(bishopPoints.negativeDiagonalUpperBound) / Piece.boardSize)
	for i in range(2):
		lineThicknesses.append(thickness)
		lineColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		lineColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

func addRookLines(state: BoardState) -> void:
	var rookPoints: PieceLogic.RookMovePoints = state.movePoints[state.findPieceIndex(pieceDraggingPreviousState)] as PieceLogic.RookMovePoints
	lineStarts.append(Vector2(rookPoints.horizontalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(rookPoints.horizontalUpperBound) / Piece.boardSize)
	lineStarts.append(Vector2(rookPoints.verticalLowerBound) / Piece.boardSize)
	lineEnds.append(Vector2(rookPoints.verticalUpperBound) / Piece.boardSize)
	for i in range(2):
		lineThicknesses.append(thickness)
		lineColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		lineColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

func addQueenLines(state: BoardState) -> void:
	var queenPoints: PieceLogic.QueenMovePoints = state.movePoints[state.findPieceIndex(pieceDraggingPreviousState)] as PieceLogic.QueenMovePoints
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

func addKingLines(state: BoardState) -> void:
	var kingPoints: PieceLogic.KingMovePoints = state.movePoints[state.findPieceIndex(pieceDraggingPreviousState)] as PieceLogic.KingMovePoints
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

var castleRadius: int = Piece.boardSize / 16
func addCastleArea(center: Vector2i) -> void:
	circleCenters.append(Vector2(center) / Vector2(Piece.boardSize, Piece.boardSize))
	circleRadii.append(float(castleRadius) / float(Piece.boardSize))
	circleColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
	circleColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

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
	var totalCaptures = 0
	for i in range(len(state.pieces)):
		var capturer: Piece = state.pieces[i]
		var piecesCanCapture: Array[Piece] = state.piecesCanCapture[i]
		for capturee: Piece in piecesCanCapture:
			totalCaptures += 1
			arrowStarts.append(Vector2(capturer.pos) / Piece.boardSize)
			arrowEnds.append(Vector2(capturee.pos) / Piece.boardSize)
			if capturer.color == Piece.PieceColor.WHITE:
				arrowColorsrg.append(Vector2(whiteCapturerArrowColor.r, whiteCapturerArrowColor.g))
				arrowColorsba.append(Vector2(whiteCapturerArrowColor.b, whiteCapturerArrowColor.a))
			else:
				arrowColorsrg.append(Vector2(blackCapturerArrowColor.r, blackCapturerArrowColor.g))
				arrowColorsba.append(Vector2(blackCapturerArrowColor.b, blackCapturerArrowColor.a))
			arrowThicknesses.append(arrowThickness)
			arrowDistortPoints.append(((Vector2(capturer.pos) + Vector2(capturee.pos)) / 2 - Vector2(0, Piece.hitRadius) * (0.333 if capturer.color == Piece.PieceColor.WHITE else 0.666)) / Piece.boardSize)
	print(totalCaptures)
		
