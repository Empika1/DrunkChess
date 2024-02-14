extends Sprite2D
class_name BoardRenderer

@export var pieceHolder: Node2D

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
		sprite.hitSprite.visible = pieceDragging != null
		
	for col in [Piece.PieceColor.BLACK, Piece.PieceColor.WHITE]:
		for key in freePiecePool[col]:
			var arr: Array = freePiecePool[col][key]
			for piece in arr:
				piece.global_position = shadowRealm
	
