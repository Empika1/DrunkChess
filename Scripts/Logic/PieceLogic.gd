extends RefCounted
class_name PieceLogic

static func doPiecesOverlap(pos1: Vector2i, radius1: int, pos2: Vector2i, radius2: int) -> bool:
	var x_diff: int = abs(pos1.x - pos2.x)
	var y_diff: int = abs(pos1.y - pos2.y)
	var distance_squared: int = x_diff * x_diff + y_diff * y_diff

	var sum_radii: int = radius1 + radius2
	var sum_radii_squared: int = sum_radii ** 2

	return distance_squared < sum_radii_squared

static func isPieceOutsideBoard(pos: Vector2i, radius: int, maxPos: Vector2i) -> bool:
	return pos.x - radius < 0 or pos.y - radius < 0 or pos.x + radius > maxPos.x or pos.y + radius > maxPos.y

static func canRookMoveTo(rook: Piece, pieces: Array[Piece], movePos: Vector2i) -> bool:
	return closestPosCanRookMoveTo(rook, pieces, movePos) == movePos

static func closestPosCanRookMoveTo(rook: Piece, pieces: Array[Piece], tryMovePos: Vector2i) -> Vector2i:
	var posOnVertical: Vector2i = Vector2i(rook.pos.x, tryMovePos.y)
	for piece: Piece in pieces:
		if piece.color != rook.color or piece.valueEquals(rook):
			continue #fix
		var intersections: Array[Vector2i] = Geometry.verticalLineCircleIntersections(posOnVertical.x, piece.pos, piece.hitRadius + rook.hitRadius)
		for intersection: Vector2i in intersections:
			#print(Piece.PieceType.keys()[piece.type], " ", Piece.PieceColor.keys()[piece.color], " ", intersection)
			if (intersection.y < posOnVertical.y and intersection.y > rook.pos.y) or (intersection.y > posOnVertical.y and intersection.y < rook.pos.y):
				posOnVertical.y = intersection.y
	
	var posOnHorizontal: Vector2i = Vector2i(tryMovePos.x, rook.pos.y)
	for piece: Piece in pieces:
		if piece.color != rook.color or piece.valueEquals(rook):
			continue
		var intersections: Array[Vector2i] = Geometry.horizontalLineCircleIntersections(posOnVertical.y, piece.pos, piece.hitRadius + rook.hitRadius)
		for intersection: Vector2i in intersections:
			print(intersection, " ", posOnHorizontal, " ", rook.pos)
			if (intersection.x < posOnHorizontal.x and intersection.x > rook.pos.x) or (intersection.x > posOnHorizontal.x and intersection.x < rook.pos.x):
				posOnHorizontal.x = intersection.x
	
	return posOnHorizontal
	return posOnVertical if (posOnVertical - tryMovePos).length_squared() < (posOnHorizontal - tryMovePos).length_squared() else posOnHorizontal

static func closestPosCanMoveTo(piece: Piece, pieces: Array[Piece], tryMovePos: Vector2i) -> Vector2i:
	match piece.type:
		Piece.PieceType.ROOK:
			return closestPosCanRookMoveTo(piece, pieces, tryMovePos)
		_:
			return piece.pos
