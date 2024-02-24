extends Sprite2D
class_name BoardRenderer

@export var pieceHolder: Node2D
@export var lines: Sprite2D
@export var circles: Sprite2D
@export var circleArcs: Sprite2D

@onready var states: Array[BoardState] = [BoardState.newDefaultStartingState()]

const shadowRealm: Vector2 = Vector2(9999999, 9999999)
var pieceScene: PackedScene = preload("res://Prefabs/DraggablePiece.tscn")
var usedPiecePool: Dictionary
var freePiecePool: Dictionary
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
		var sprite: DraggablePiece = pieceScene.instantiate()
		freePiecePool[piece.color][piece.type].append(sprite)
		pieceHolder.add_child(sprite)
		sprite.init(self, piece)
	
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
	return Vector2(boardLength) / Vector2(Piece.maxPos) * getScaledRectSize()

func boardPosToGamePos(boardPos: Vector2i) -> Vector2:
	return boardLengthToGameLength(boardPos) + global_position

func gameLengthToBoardLength(gameLength: Vector2) -> Vector2i:
	return Vector2i(gameLength * Vector2(Piece.maxPos) / getScaledRectSize())

func gamePosToBoardPos(gamePos: Vector2) -> Vector2i:
	return gameLengthToBoardLength(gamePos - global_position)

func getHoveredPiece(mousePos: Vector2i) -> Piece:
	for c in pieceHolder.get_children():
		var cs = c as DraggablePiece
		var distanceSquared = (cs.global_position.x - mousePos.x) ** 2 + (cs.global_position.y - mousePos.y) ** 2
		if distanceSquared < (float(c.piece.hitRadius) / Piece.maxPos.x * getScaledRectSize().x) ** 2:
			return cs.piece
	return null

var pieceDraggingPreviousState: Piece
var pieceDraggingNextState: Piece
var dragOffset: Vector2i
var attemptedNextState: BoardState
var stateToRender: BoardState
func render() -> void:
	deleteCircles(); deleteLines(); deleteArcs();
	var mousePos: Vector2i = get_viewport().get_mouse_position()
	if pieceDraggingPreviousState == null && Input.is_action_just_pressed("lmb"):
		pieceDraggingPreviousState = getHoveredPiece(mousePos)
		if pieceDraggingPreviousState != null:
			dragOffset = boardPosToGamePos(pieceDraggingPreviousState.pos) - Vector2(mousePos)
	
	if pieceDraggingPreviousState != null:
		var movePos: Vector2i = PieceLogic.closestPosCanMoveTo(pieceDraggingPreviousState, states[-1].pieces, gamePosToBoardPos(mousePos + dragOffset))
		var move: Move = Move.newNormal(pieceDraggingPreviousState, movePos)
		pieceDraggingNextState = pieceDraggingPreviousState.duplicate()
		pieceDraggingNextState.pos = movePos
		attemptedNextState = states[-1].makeMove(move)
		
		if Input.is_action_just_released("lmb"):
			if attemptedNextState.result == BoardState.StateResult.VALID:
				states.append(attemptedNextState)
			attemptedNextState = null
			pieceDraggingPreviousState = null
			pieceDraggingNextState = null
			dragOffset = Vector2i.ZERO

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
		sprite.piece = piece
		usedPiecePool[piece.color][piece.type].append(sprite)
		sprite.global_position = boardPosToGamePos(piece.pos)
		sprite.global_scale = global_scale
	
	if pieceDraggingPreviousState != null:
		addHitRadii(stateToRender.pieces)
		addMoveIndicators(states[-1])
	
	for col in [Piece.PieceColor.BLACK, Piece.PieceColor.WHITE]:
		for key in freePiecePool[col]:
			var arr: Array = freePiecePool[col][key]
			for piece in arr:
				piece.global_position = shadowRealm
	
	setCircles(); setLines(); setArcs();

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
		circleCenters.append(Vector2(piece.pos) / Vector2(Piece.boardSize))
		circleRadii.append(float(piece.hitRadius) / float(Piece.boardSize.x))
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
	var pawnPoints: PieceLogic.PawnMovePoints = PieceLogic.calculatePawnMovePoints(pieceDraggingPreviousState, state.pieces)
	lineStarts.append(Vector2(pawnPoints.verticalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(pawnPoints.verticalUpperBound) / Vector2(Piece.maxPos))
	lineStarts.append(Vector2(pawnPoints.positiveDiagonalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(pawnPoints.positiveDiagonalUpperBound) / Vector2(Piece.maxPos))
	lineStarts.append(Vector2(pawnPoints.negativeDiagonalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(pawnPoints.negativeDiagonalUpperBound) / Vector2(Piece.maxPos))
	for i in range(3):
		lineThicknesses.append(thickness)
		lineColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		lineColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

func addKnightArcs(state: BoardState) -> void:
	var knightPoints: PieceLogic.KnightMovePoints = PieceLogic.calculateKnightMovePoints(pieceDraggingPreviousState, state.pieces)
	arcCenters.append(Vector2(pieceDraggingPreviousState.pos) / Vector2(Piece.maxPos))
	arcRadii.append(float(pieceDraggingPreviousState.knightMoveRadius) / float(Piece.maxPos.x))
	arcColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
	arcColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))
	arcThicknesses.append(thickness)
	arcEndIndices.append(knightPoints.arcEnds.size())
	for i in range(knightPoints.arcStarts.size()):
		arcStarts.append(Vector2(knightPoints.arcStarts[i]) / Vector2(Piece.boardSize))
		arcEnds.append(Vector2(knightPoints.arcEnds[i]) / Vector2(Piece.boardSize))
		
func addBishopLines(state: BoardState) -> void:
	var bishopPoints: PieceLogic.BishopMovePoints = PieceLogic.calculateBishopMovePoints(pieceDraggingPreviousState, state.pieces)
	lineStarts.append(Vector2(bishopPoints.positiveDiagonalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(bishopPoints.positiveDiagonalUpperBound) / Vector2(Piece.maxPos))
	lineStarts.append(Vector2(bishopPoints.negativeDiagonalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(bishopPoints.negativeDiagonalUpperBound) / Vector2(Piece.maxPos))
	for i in range(2):
		lineThicknesses.append(thickness)
		lineColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		lineColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

func addRookLines(state: BoardState) -> void:
	var rookPoints: PieceLogic.RookMovePoints = PieceLogic.calculateRookMovePoints(pieceDraggingPreviousState, state.pieces)
	lineStarts.append(Vector2(rookPoints.horizontalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(rookPoints.horizontalUpperBound) / Vector2(Piece.maxPos))
	lineStarts.append(Vector2(rookPoints.verticalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(rookPoints.verticalUpperBound) / Vector2(Piece.maxPos))
	for i in range(2):
		lineThicknesses.append(thickness)
		lineColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		lineColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

func addQueenLines(state: BoardState) -> void:
	var queenPoints: PieceLogic.QueenMovePoints = PieceLogic.calculateQueenMovePoints(pieceDraggingPreviousState, state.pieces)
	lineStarts.append(Vector2(queenPoints.positiveDiagonalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(queenPoints.positiveDiagonalUpperBound) / Vector2(Piece.maxPos))
	lineStarts.append(Vector2(queenPoints.negativeDiagonalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(queenPoints.negativeDiagonalUpperBound) / Vector2(Piece.maxPos))
	lineStarts.append(Vector2(queenPoints.horizontalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(queenPoints.horizontalUpperBound) / Vector2(Piece.maxPos))
	lineStarts.append(Vector2(queenPoints.verticalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(queenPoints.verticalUpperBound) / Vector2(Piece.maxPos))
	for i in range(4):
		lineThicknesses.append(thickness)
		lineColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		lineColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

func addKingLines(state: BoardState) -> void:
	var kingPoints: PieceLogic.KingMovePoints = PieceLogic.calculateKingMovePoints(pieceDraggingPreviousState, state.pieces)
	lineStarts.append(Vector2(kingPoints.positiveDiagonalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(kingPoints.positiveDiagonalUpperBound) / Vector2(Piece.maxPos))
	lineStarts.append(Vector2(kingPoints.negativeDiagonalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(kingPoints.negativeDiagonalUpperBound) / Vector2(Piece.maxPos))
	lineStarts.append(Vector2(kingPoints.horizontalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(kingPoints.horizontalUpperBound) / Vector2(Piece.maxPos))
	lineStarts.append(Vector2(kingPoints.verticalLowerBound) / Vector2(Piece.maxPos))
	lineEnds.append(Vector2(kingPoints.verticalUpperBound) / Vector2(Piece.maxPos))
	for i in range(4):
		lineThicknesses.append(thickness)
		lineColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		lineColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))
