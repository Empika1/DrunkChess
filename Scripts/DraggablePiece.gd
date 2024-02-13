extends Sprite2D
class_name DraggablePiece

const shadowRealm: Vector2 = Vector2(99999, 99999)

@export var hitSprite: Sprite2D
@export var moveSprite: Sprite2D
var renderer: BoardRenderer

var piece: Piece

func setPiece(piece_: Piece):
	piece = piece_
	var mat: ShaderMaterial = hitSprite.material as ShaderMaterial
	mat.set_shader_parameter("radius", renderer.boardLengthToGameLength(Vector2i(piece.hitRadius, piece.hitRadius)))
	
	hitSprite.visible = false
	#moveSprite.visible = false
	
func init(renderer_: BoardRenderer, piece_: Piece):
	renderer = renderer_
	texture = renderer.getPieceTexture(piece_.type, piece_.color)
	setPiece(piece_)
