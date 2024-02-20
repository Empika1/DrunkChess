extends Sprite2D
class_name BoardRenderer

@export var pieceHolder: Node2D
@export var lines: Sprite2D
@export var circles: Sprite2D
@export var arcs: Sprite2D

@onready var states: Array[BoardState] = [BoardState.newDefaultStartingState()]

const shadowRealm: Vector2 = Vector2(9999999, 9999999)
var pieceScene: PackedScene = preload("res://Prefabs/DraggablePiece.tscn")
var usedPiecePool: Dictionary
var freePiecePool: Dictionary
func _ready() -> void:
	var inter = Geometry.diagonalLinesIntersection(Vector2i(4096, 36864), Vector2i(-5992, 26775), true, true)
	print(inter)
	
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

var pieceDragging: Piece
var dragOffset: Vector2i
var attemptedNextState: BoardState
func render() -> void:
	var mousePos: Vector2i = get_viewport().get_mouse_position()
	if pieceDragging == null && Input.is_action_just_pressed("lmb"):
		pieceDragging = getHoveredPiece(mousePos)
		if pieceDragging != null:
			dragOffset = boardPosToGamePos(pieceDragging.pos) - Vector2(mousePos)
	
	if pieceDragging != null:
		var move: Move = Move.newNormal(pieceDragging, PieceLogic.closestPosCanMoveTo(pieceDragging, states[-1].pieces, gamePosToBoardPos(mousePos + dragOffset)))
		attemptedNextState = states[-1].makeMove(move)
		
		if Input.is_action_just_released("lmb"):
			if attemptedNextState.result == BoardState.StateResult.VALID:
				states.append(attemptedNextState)
			attemptedNextState = null
			pieceDragging = null
			dragOffset = Vector2i.ZERO
			
	var stateToRender: BoardState
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
	
	if pieceDragging != null:
		addHitRadii(stateToRender.pieces)
		if pieceDragging.type == Piece.PieceType.KNIGHT:
			addKnightArcs(stateToRender)
	else:
		removeHitRadii()
		#removeKnightArcs()
	
	for col in [Piece.PieceColor.BLACK, Piece.PieceColor.WHITE]:
		for key in freePiecePool[col]:
			var arr: Array = freePiecePool[col][key]
			for piece in arr:
				piece.global_position = shadowRealm

@export var hitRadiusColor: Color
func addHitRadii(pieces: Array[Piece]) -> void:
	var centers: PackedVector2Array = PackedVector2Array()
	var radii: PackedFloat32Array = PackedFloat32Array()
	var colorsrg: PackedVector2Array = PackedVector2Array()
	var colorsba: PackedVector2Array = PackedVector2Array()
	
	for piece in pieces:
		centers.append(Vector2(piece.pos) / Vector2(Piece.boardSize))
		radii.append(float(piece.hitRadius) / float(Piece.boardSize.x))
		colorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		colorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))
	
	var mat: ShaderMaterial = circles.material as ShaderMaterial
	mat.set_shader_parameter("circleCenters", centers)
	mat.set_shader_parameter("circleRadii", radii)
	mat.set_shader_parameter("circleColorsrg", colorsrg)
	mat.set_shader_parameter("circleColorsba", colorsba)

func removeHitRadii() -> void:
	var mat: ShaderMaterial = circles.material as ShaderMaterial
	mat.set_shader_parameter("circleCenters", PackedVector2Array())
	mat.set_shader_parameter("circleRadii", PackedFloat32Array())
	mat.set_shader_parameter("circleColorsrg", PackedVector2Array())
	mat.set_shader_parameter("circleColorsba", PackedVector2Array())

@export var thickness: float
func addKnightArcs(stateToRender: BoardState) -> void:
	var knightPoints: PieceLogic.KnightMovePoints = PieceLogic.calculateKnightMovePoints(pieceDragging, stateToRender.pieces)
	
	var centers: PackedVector2Array = PackedVector2Array()
	var radii: PackedFloat32Array = PackedFloat32Array()
	var thicknesses: PackedFloat32Array = PackedFloat32Array()
	var colorsrg: PackedVector2Array = PackedVector2Array()
	var colorsba: PackedVector2Array = PackedVector2Array()
	var arcStarts: PackedVector2Array = PackedVector2Array()
	var arcEnds: PackedVector2Array = PackedVector2Array()
	
	for i in range(knightPoints.arcStarts.size()):
		centers.append(Vector2(pieceDragging.pos) / Vector2(Piece.boardSize))
		print("c ", Vector2(pieceDragging.pos) / Vector2(Piece.boardSize))
		radii.append(float(pieceDragging.knightMoveRadius) / float(Piece.boardSize.x) + thickness / 2)
		print("r ", float(pieceDragging.knightMoveRadius) / float(Piece.boardSize.x) + thickness / 2)
		thicknesses.append(thickness)
		print("t, ", thickness)
		colorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
		print("colrg ", Vector2(hitRadiusColor.r, hitRadiusColor.g))
		colorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))
		print("colba ", Vector2(hitRadiusColor.b, hitRadiusColor.a))
		arcStarts.append(Vector2(knightPoints.arcStarts[i]) / Vector2(Piece.boardSize))
		print("as ", Vector2(knightPoints.arcStarts[i]) / Vector2(Piece.boardSize))
		arcEnds.append(Vector2(knightPoints.arcEnds[i]) / Vector2(Piece.boardSize))
		print("ae ", Vector2(knightPoints.arcEnds[i]) / Vector2(Piece.boardSize))
	
	var mat: ShaderMaterial = arcs.material as ShaderMaterial
	mat.set_shader_parameter("arcCenters", centers)
	mat.set_shader_parameter("arcRadii", radii)
	mat.set_shader_parameter("arcThicknesses", thicknesses)
	mat.set_shader_parameter("arcColorsrg", colorsrg)
	mat.set_shader_parameter("arcColorsba", colorsba)
	mat.set_shader_parameter("arcStarts", arcStarts)
	mat.set_shader_parameter("arcEnds", arcEnds)

func removeKnightArcs() -> void:
	var mat: ShaderMaterial = arcs.material as ShaderMaterial
	mat.set_shader_parameter("arcCenters", PackedVector2Array())
	mat.set_shader_parameter("arcRadii", PackedFloat32Array())
	mat.set_shader_parameter("arcThicknesses", PackedVector2Array())
	mat.set_shader_parameter("arcColorsrg", PackedVector2Array())
	mat.set_shader_parameter("arcColorsba", PackedVector2Array())
	mat.set_shader_parameter("arcStarts", PackedVector2Array())
	mat.set_shader_parameter("arcEnds", PackedVector2Array())
