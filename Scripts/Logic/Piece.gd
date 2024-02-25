extends RefCounted

class_name Piece

enum PieceType {
	PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING, NULL_PIECE
}

func isPromotableTo(pieceType: PieceType) -> bool:
	match pieceType:
		PieceType.PAWN:
			return false
		PieceType.KING:
			return false
		_:
			return true
			
enum PieceColor {WHITE, BLACK}

var pos: Vector2i
var type: PieceType
var color: PieceColor
var hasMoved: bool
const boardSize: int = 2 ** 16
const squareSize: int = boardSize / 8
const hitRadius: int = int(float(boardSize) / 8. / 2. * sqrt(2) / 2.)

const knightMoveRadius: int = int(sqrt(2 ** 2 + 1 ** 2) * boardSize / 8)

func getHitRadius(_pieceType: PieceType):
	return hitRadius

func _init(pos_: Vector2i, type_: PieceType, color_: PieceColor, hasMoved_: bool = false):
	pos = pos_
	type = type_
	color = color_
	hasMoved = hasMoved_
	
func duplicate() -> Piece:
	return Piece.new(pos, type, color, hasMoved)
	
func valueEquals(other: Piece) -> bool:
	return pos == other.pos && type == other.type && color == other.color && hasMoved == other.hasMoved;
	
func toString() -> String:
	return PieceColor.keys()[color] + " " + PieceType.keys()[type] + " at " + str(pos) + (" that has moved" if hasMoved else " that hasn't moved")
