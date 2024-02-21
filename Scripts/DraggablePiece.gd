extends Sprite2D
class_name DraggablePiece

var renderer: BoardRenderer

var piece: Piece
	
func init(renderer_: BoardRenderer, piece_: Piece):
	renderer = renderer_
	texture = renderer.getPieceTexture(piece_.type, piece_.color)
my 