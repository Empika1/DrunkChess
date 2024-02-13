class_name BoardRenderer
extends Sprite2D

@export var pieceHolder: Node2D

@onready var states: Array[BoardState] = [BoardState.newDefaultStartingState()]

func _ready() -> void:
	pass
	
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
var spriteScene: PackedScene = preload("res://Prefabs/DraggablePiece.tscn")
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
	#print(stateToRender.toString())
			
	for c in pieceHolder.get_children():
		pieceHolder.remove_child(c)
		c.queue_free()

	for piece in stateToRender.pieces:
		var sprite: DraggablePiece = spriteScene.instantiate()
		pieceHolder.add_child(sprite)
		sprite.piece = piece
		sprite.texture = getPieceTexture(piece.type, piece.color)
		sprite.global_position = boardPosToGamePos(piece.pos)
		sprite.global_scale = global_scale
	
