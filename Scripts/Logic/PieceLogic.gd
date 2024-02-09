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

static func closestPosBishopCanMoveTo(bishop: Piece, pieces: Array[Piece], tryMovePos: Vector2i) -> Vector2i:
	var posOnPositiveDiagonal = Geometry.diagonalLinesIntersection(bishop.pos, tryMovePos, true, true)
	for piece: Piece in pieces:
		if piece.valueEquals(bishop):
			continue
	
		var intersections: Array[Vector2i] = Geometry.positiveDiagonalLineCircleIntersections(bishop.pos.y - bishop.pos.x, piece.pos, piece.hitRadius + bishop.hitRadius)
		if piece.color == bishop.color:
			for intersection: Vector2i in intersections:
				print(intersection.y == bishop.pos.y and sign(posOnPositiveDiagonal.y - intersection.y) == sign(piece.pos.y - intersection.y))
				if (intersection.x < posOnPositiveDiagonal.x and intersection.x > bishop.pos.x) or 	(intersection.x > posOnPositiveDiagonal.x and intersection.x < bishop.pos.x) or (intersection.x == bishop.pos.x and sign(posOnPositiveDiagonal.x - intersection.x) == sign(piece.pos.x - intersection.x)):
					posOnPositiveDiagonal = intersection
		else:
			if intersections.size() > 0:
				var intersectionPos: Vector2i = Geometry.diagonalLinesIntersection(bishop.pos, piece.pos, true, true)
				if (posOnPositiveDiagonal - bishop.pos).length_squared() > (intersectionPos - bishop.pos).length_squared() and sign(posOnPositiveDiagonal.x - bishop.pos.x) == sign(intersectionPos.x - bishop.pos.x):
					posOnPositiveDiagonal = intersectionPos
	
	var posOnPositiveDiagonalClampedX: int = clamp(posOnPositiveDiagonal.x, bishop.hitRadius, bishop.maxPos.x - bishop.hitRadius)
	posOnPositiveDiagonal.y -= posOnPositiveDiagonal.x - posOnPositiveDiagonalClampedX
	posOnPositiveDiagonal.x = posOnPositiveDiagonalClampedX
	var posOnPositiveDiagonalClampedY: int = clamp(posOnPositiveDiagonal.y, bishop.hitRadius, bishop.maxPos.y - bishop.hitRadius)
	posOnPositiveDiagonal.x -= posOnPositiveDiagonal.y - posOnPositiveDiagonalClampedY
	posOnPositiveDiagonal.y = posOnPositiveDiagonalClampedY

	var posOnNegativeDiagonal = Geometry.diagonalLinesIntersection(tryMovePos, bishop.pos, false, true)
	for piece: Piece in pieces:
		if piece.valueEquals(bishop):
			continue
			
		var intersections: Array[Vector2i] = Geometry.negativeDiagonalLineCircleIntersections(bishop.pos.y + bishop.pos.x, piece.pos, piece.hitRadius + bishop.hitRadius)
		if piece.color == bishop.color:
			for intersection: Vector2i in intersections:
				#print("neg ", (intersection.x <= posOnNegativeDiagonal.x and intersection.x >= bishop.pos.x) or (intersection.x >= posOnNegativeDiagonal.x and intersection.x <= bishop.pos.x))
				if (intersection.x < posOnNegativeDiagonal.x and intersection.x > bishop.pos.x) or 	(intersection.x > posOnNegativeDiagonal.x and intersection.x < bishop.pos.x) or (intersection.x == bishop.pos.x and sign(posOnNegativeDiagonal.x - intersection.x) == sign(piece.pos.x - intersection.x)):
					posOnNegativeDiagonal = intersection
		else:
			if intersections.size() > 0:
				var intersectionPos: Vector2i = Geometry.diagonalLinesIntersection(piece.pos, bishop.pos, false, true)
				if (posOnNegativeDiagonal - bishop.pos).length_squared() > (intersectionPos - bishop.pos).length_squared() and sign(posOnNegativeDiagonal.x - bishop.pos.x) == sign(intersectionPos.x - bishop.pos.x):
					posOnNegativeDiagonal = intersectionPos
	
	var posOnNegativeDiagonalClampedX: int = clamp(posOnNegativeDiagonal.x, bishop.hitRadius, bishop.maxPos.x - bishop.hitRadius)
	posOnNegativeDiagonal.y += posOnNegativeDiagonal.x - posOnNegativeDiagonalClampedX
	posOnNegativeDiagonal.x = posOnNegativeDiagonalClampedX
	var posOnNegativeDiagonalClampedY: int = clamp(posOnNegativeDiagonal.y, bishop.hitRadius, bishop.maxPos.y - bishop.hitRadius)
	posOnNegativeDiagonal.x += posOnNegativeDiagonal.y - posOnNegativeDiagonalClampedY
	posOnNegativeDiagonal.y = posOnNegativeDiagonalClampedY		
	return posOnPositiveDiagonal if (posOnPositiveDiagonal - tryMovePos).length_squared() < (posOnNegativeDiagonal - tryMovePos).length_squared() else posOnNegativeDiagonal

static func closestPosRookCanMoveTo(rook: Piece, pieces: Array[Piece], tryMovePos: Vector2i) -> Vector2i:
	var posOnVertical: Vector2i = Vector2i(rook.pos.x, tryMovePos.y)
	for piece: Piece in pieces:
		if piece.valueEquals(rook):
			continue
		
		var intersections: Array[Vector2i] = Geometry.verticalLineCircleIntersections(posOnVertical.x, piece.pos, piece.hitRadius + rook.hitRadius)
		if piece.color == rook.color:
			for intersection: Vector2i in intersections:
				if (intersection.y < posOnVertical.y and intersection.y > rook.pos.y) or (intersection.y > posOnVertical.y and intersection.y < rook.pos.y):
					posOnVertical.y = intersection.y
		else:
			if intersections.size() > 0:
				if (piece.pos.y < posOnVertical.y and piece.pos.y > rook.pos.y) or (piece.pos.y > posOnVertical.y and piece.pos.y < rook.pos.y):
					posOnVertical.y = piece.pos.y
					
	posOnVertical.y = clampi(posOnVertical.y, rook.hitRadius, rook.maxPos.y - rook.hitRadius)
	
	var posOnHorizontal: Vector2i = Vector2i(tryMovePos.x, rook.pos.y)
	for piece: Piece in pieces:
		if piece.valueEquals(rook):
			continue
		
		var intersections: Array[Vector2i] = Geometry.horizontalLineCircleIntersections(posOnHorizontal.y, piece.pos, piece.hitRadius + rook.hitRadius)
		if piece.color == rook.color:
			for intersection: Vector2i in intersections:
				if (intersection.x < posOnHorizontal.x and intersection.x > rook.pos.x) or (intersection.x > posOnHorizontal.x and intersection.x < rook.pos.x):
					posOnHorizontal.x = intersection.x
		else:
			if intersections.size() > 0:
				if (piece.pos.x < posOnHorizontal.x and piece.pos.x > rook.pos.x) or (piece.pos.x > posOnHorizontal.x and piece.pos.x < rook.pos.x):
					posOnHorizontal.x = piece.pos.x
					
	posOnHorizontal.x = clampi(posOnHorizontal.x, rook.hitRadius, rook.maxPos.x - rook.hitRadius)
	
	return posOnVertical if (posOnVertical - tryMovePos).length_squared() < (posOnHorizontal - tryMovePos).length_squared() else posOnHorizontal

static func closestPosQueenCanMoveTo(queen: Piece, pieces: Array[Piece], tryMovePos: Vector2i) -> Vector2i:
	var rookPos: Vector2i = closestPosRookCanMoveTo(queen, pieces, tryMovePos)
	var bishopPos: Vector2i = closestPosBishopCanMoveTo(queen, pieces, tryMovePos)
	return bishopPos if (bishopPos - tryMovePos).length_squared() < (rookPos - tryMovePos).length_squared() else rookPos

static func closestPosCanMoveTo(piece: Piece, pieces: Array[Piece], tryMovePos: Vector2i) -> Vector2i:
	match piece.type:
		Piece.PieceType.BISHOP:
			return closestPosBishopCanMoveTo(piece, pieces, tryMovePos)
		Piece.PieceType.ROOK:
			return closestPosRookCanMoveTo(piece, pieces, tryMovePos)
		Piece.PieceType.QUEEN:
			return closestPosQueenCanMoveTo(piece, pieces, tryMovePos)
		_:
			return tryMovePos
			
static func canPieceMoveTo(piece: Piece, pieces: Array[Piece], tryMovePos: Vector2i) -> bool:
	return closestPosCanMoveTo(piece, pieces, tryMovePos) == tryMovePos
