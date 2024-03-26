extends RefCounted
class_name Move

enum MoveType {
	NORMAL, PROMOTION, CASTLE, NULL_MOVE_TYPE
}

func isOnePiece(moveType_: MoveType) -> bool:
	match moveType_:
		MoveType.CASTLE:
			return false
		_:
			return true

var moveType: MoveType
var movedPiece: Piece #only for normal and promote move
var posMovedTo: Vector2i #only for normal and promote move
var promotingTo: Piece.PieceType #only for promote move
var movedKing: Piece #only for castle move
var movedRook: Piece #only for castle move

func _init(moveType_: MoveType, movedPiece_: Piece, posMovedTo_: Vector2i, promotingTo_: Piece.PieceType, movedKing_: Piece, movedRook_: Piece):
	moveType = moveType_
	movedPiece = movedPiece_
	posMovedTo = posMovedTo_
	promotingTo = promotingTo_
	movedKing = movedKing_
	movedRook = movedRook_

static func newNormal(movedPiece_: Piece, posMovedTo_: Vector2i) -> Move:
	var moveType__: MoveType = MoveType.NORMAL
	var movedPiece__: Piece = movedPiece_
	var posMovedTo__: Vector2i = posMovedTo_
	
	var promotingTo__: Piece.PieceType = Piece.PieceType.NULL_PIECE
	var movedKing__: Piece = null
	var movedRook__: Piece = null

	return Move.new(moveType__, movedPiece__, posMovedTo__, promotingTo__, movedKing__, movedRook__)
	
static func newPromotion(movedPiece_: Piece, posMovedTo_: Vector2i, promotingTo_: Piece.PieceType) -> Move:
	var moveType__: MoveType = MoveType.PROMOTION
	var movedPiece__: Piece = movedPiece_
	var posMovedTo__: Vector2i = posMovedTo_
	var promotingTo__: Piece.PieceType = promotingTo_
	
	var movedKing__: Piece = null
	var movedRook__: Piece = null
	return Move.new(moveType__, movedPiece__, posMovedTo__, promotingTo__, movedKing__, movedRook__)

static func newCastle(movedKing_: Piece, movedRook_: Piece) -> Move:
	var moveType__: MoveType = MoveType.CASTLE
	
	var movedPiece__: Piece = null
	var posMovedTo__: Vector2i = Vector2i(0, 0)
	var promotingTo__: Piece.PieceType = Piece.PieceType.NULL_PIECE
	
	var movedKing__: Piece = movedKing_
	var movedRook__: Piece = movedRook_
	return Move.new(moveType__, movedPiece__, posMovedTo__, promotingTo__, movedKing__, movedRook__)

func duplicate():
	return Move.new(moveType, movedPiece.duplicate() if movedPiece != null else null, posMovedTo, 
	promotingTo, movedKing.duplicate() if movedKing != null else null, 
	movedRook.duplicate() if movedRook != null else null)
