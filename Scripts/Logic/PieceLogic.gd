extends RefCounted
class_name PieceLogic

static func doPiecesOverlap(pos1: Vector2i, radius1: int, pos2: Vector2i, radius2: int) -> bool:
	return (pos1 - pos2).length_squared() < (radius1 + radius2) ** 2

static func isPieceOutsideBoard(pos: Vector2i, radius: int, maxPos: Vector2i) -> bool:
	return pos.x - radius < 0 or pos.y - radius < 0 or pos.x + radius > maxPos.x or pos.y + radius > maxPos.y

static func closestPosPawnCanMoveTo(pawn: Piece, pieces: Array[Piece], tryMovePos: Vector2i) -> Vector2i:
	var posOnVertical: Vector2i = Vector2i(pawn.pos.x, tryMovePos.y)
	
	for piece: Piece in pieces:
		if piece.valueEquals(pawn):
			continue
		
		var intersections: Array[Vector2i] = Geometry.verticalLineCircleIntersections(posOnVertical.x, piece.pos, piece.hitRadius + pawn.hitRadius)
		for intersection: Vector2i in intersections:
			if (intersection.y < posOnVertical.y and intersection.y > pawn.pos.y) or (intersection.y > posOnVertical.y and intersection.y < pawn.pos.y) or (intersection.y == pawn.pos.y and sign(posOnVertical.y - intersection.y) == sign(piece.pos.y - intersection.y)):
				posOnVertical.y = intersection.y
					
	posOnVertical.y = clampi(posOnVertical.y, pawn.hitRadius, pawn.maxPos.y - pawn.hitRadius)
	if pawn.color == Piece.PieceColor.WHITE:
		posOnVertical.y = clampi(posOnVertical.y, pawn.pos.y - (Piece.squareSize.y if pawn.hasMoved else Piece.squareSize.y * 2), pawn.pos.y)
	else:
		posOnVertical.y = clampi(posOnVertical.y, pawn.pos.y, pawn.pos.y + (Piece.squareSize.y if pawn.hasMoved else Piece.squareSize.y * 2))
	
	var positiveDiagonalInterestingPoints: Array[Vector2i] = []
	var canMoveToPositiveDiagonal: Callable = func(pos: Vector2i) -> bool:
		if isPieceOutsideBoard(pos, pawn.hitRadius, Piece.maxPos):
			print("point outside board")
			return false
			
		if pos.y > pawn.pos.y:
			print("point y big")
			return false
		if pos.y < pawn.pos.y - Piece.squareSize.y:
			print("point y small")
			return false
		
		var overlapsWithSameColor: bool = false
		for piece in pieces:
			if piece.valueEquals(pawn):
				continue
				
			if piece.color == pawn.color:
				if doPiecesOverlap(pos, pawn.hitRadius, piece.pos, piece.hitRadius):
					print("point piece overlap same")
					return false
			else:
				if !overlapsWithSameColor and doPiecesOverlap(pos, pawn.hitRadius, piece.pos, piece.hitRadius):
					overlapsWithSameColor = true
		
		if !overlapsWithSameColor:
			print("point no overlap different")
		return overlapsWithSameColor
	
	var finalPosOnPositiveDiagonal: Vector2i
	var posOnPositiveDiagonal: Vector2i = Geometry.diagonalLinesIntersection(pawn.pos, tryMovePos, true, true)
	
	if canMoveToPositiveDiagonal.call(posOnPositiveDiagonal):
		finalPosOnPositiveDiagonal = posOnPositiveDiagonal
	else:
		for piece: Piece in pieces:
			if piece.valueEquals(pawn):
				continue
		
			var intersections: Array[Vector2i]
			if piece.color == pawn.color:
				intersections = Geometry.positiveDiagonalLineCircleIntersections(pawn.pos.y - pawn.pos.x, piece.pos, piece.hitRadius + pawn.hitRadius, true)
			else:
				intersections = Geometry.positiveDiagonalLineCircleIntersections(pawn.pos.y - pawn.pos.x, piece.pos, piece.hitRadius + pawn.hitRadius, false)
			positiveDiagonalInterestingPoints.append_array(intersections)
		
		var closestPointOnPositiveDiagonal = null
		for point in positiveDiagonalInterestingPoints:
			print(point)
			if closestPointOnPositiveDiagonal != null and (point - tryMovePos).length_squared() >= (closestPointOnPositiveDiagonal - tryMovePos).length_squared():
				print("point too far")
				continue
			
			if !canMoveToPositiveDiagonal.call(point):
				print("point fail")
				continue
			closestPointOnPositiveDiagonal = point
			
		finalPosOnPositiveDiagonal = closestPointOnPositiveDiagonal if closestPointOnPositiveDiagonal != null else pawn.pos

	#var posOnNegativeDiagonal: Vector2i = Geometry.diagonalLinesIntersection(tryMovePos, pawn.pos, false, true)
	return finalPosOnPositiveDiagonal

static func closestPosKnightCanMoveTo(knight: Piece, pieces: Array[Piece], tryMovePos: Vector2i) -> Vector2i:
	var scaledPos: Vector2 = Vector2(tryMovePos - knight.pos).normalized() * Piece.knightMoveRadius
	var roundedScaledPos: Vector2i = Vector2i(roundi(scaledPos.x), roundi(scaledPos.y)) + knight.pos
	var wantedPos: Vector2i = Geometry.spiralizePoint(roundedScaledPos, func(pos): return Geometry.isOnCircle(knight.pos, Piece.knightMoveRadius, pos))
	
	var interestingPoints: Array[Vector2i] = []
	
	for piece: Piece in pieces:
		if piece.valueEquals(knight):
			continue
		if piece.color != knight.color:
			continue
		
		var intersections: Array[Vector2i] = Geometry.circlesIntersectionInt(knight.pos, Piece.knightMoveRadius, piece.pos, knight.hitRadius + piece.hitRadius, false)
		interestingPoints.append_array(intersections)
	
	var topIntersections: Array[Vector2i] = Geometry.horizontalLineCircleIntersections(knight.hitRadius, knight.pos, Piece.knightMoveRadius, true)
	var topIntersectionsSnapped: Array[Vector2i] = []
	for intersection: Vector2i in topIntersections:
		topIntersectionsSnapped.append(Geometry.spiralizePoint(intersection, func(pos): return Geometry.isOnCircle(knight.pos, Piece.knightMoveRadius, pos) and pos.y >= knight.hitRadius))
	interestingPoints.append_array(topIntersectionsSnapped)
	
	var bottomIntersections: Array[Vector2i] = Geometry.horizontalLineCircleIntersections(knight.maxPos.y - knight.hitRadius, knight.pos, Piece.knightMoveRadius, true)
	var bottomIntersectionsSnapped: Array[Vector2i] = []
	for intersection: Vector2i in bottomIntersections:
		bottomIntersectionsSnapped.append(Geometry.spiralizePoint(intersection, func(pos): return Geometry.isOnCircle(knight.pos, Piece.knightMoveRadius, pos) and pos.y <= knight.maxPos.y - knight.hitRadius))
	interestingPoints.append_array(bottomIntersectionsSnapped)
		
	var leftIntersections: Array[Vector2i] = Geometry.verticalLineCircleIntersections(knight.hitRadius, knight.pos, Piece.knightMoveRadius, true)
	var leftIntersectionsSnapped: Array[Vector2i] = []
	for intersection: Vector2i in leftIntersections:
		leftIntersectionsSnapped.append(Geometry.spiralizePoint(intersection, func(pos): return Geometry.isOnCircle(knight.pos, Piece.knightMoveRadius, pos) and pos.x >= knight.hitRadius))
	interestingPoints.append_array(leftIntersectionsSnapped)
		
	var rightIntersections: Array[Vector2i] = Geometry.verticalLineCircleIntersections(knight.maxPos.x - knight.hitRadius, knight.pos, Piece.knightMoveRadius, true)
	var rightIntersectionsSnapped: Array[Vector2i] = []
	for intersection: Vector2i in rightIntersections:
		rightIntersectionsSnapped.append(Geometry.spiralizePoint(intersection, func(pos): return Geometry.isOnCircle(knight.pos, Piece.knightMoveRadius, pos) and pos.x <= knight.maxPos.x - knight.hitRadius))
	interestingPoints.append_array(rightIntersectionsSnapped)

	var isKnightMovable: Callable = func(pos: Vector2i):
		if isPieceOutsideBoard(pos, knight.hitRadius, knight.maxPos):
			return false
		
		var overlapsWithPiece: bool = false
		for piece in pieces:
			if piece.valueEquals(knight) or piece.color != knight.color:
				continue
			if doPiecesOverlap(pos, knight.hitRadius, piece.pos, piece.hitRadius):
				overlapsWithPiece = true
				break
		if overlapsWithPiece:
			return false
		return true
	
	if isKnightMovable.call(wantedPos):
		return wantedPos
	
	var closestValidPos = null
	for point in interestingPoints:
		if closestValidPos != null and (tryMovePos - point).length_squared() >= (tryMovePos - closestValidPos).length_squared():
			continue
		if isKnightMovable.call(point):
			closestValidPos = point
	
	if closestValidPos == null:
		return knight.pos
	return closestValidPos

static func closestPosBishopCanMoveTo(bishop: Piece, pieces: Array[Piece], tryMovePos: Vector2i) -> Vector2i:
	var posOnPositiveDiagonal = Geometry.diagonalLinesIntersection(bishop.pos, tryMovePos, true, true)
	for piece: Piece in pieces:
		if piece.valueEquals(bishop):
			continue
	
		var intersections: Array[Vector2i] = Geometry.positiveDiagonalLineCircleIntersections(bishop.pos.y - bishop.pos.x, piece.pos, piece.hitRadius + bishop.hitRadius)
		if piece.color == bishop.color:
			for intersection: Vector2i in intersections:
				if (intersection.x < posOnPositiveDiagonal.x and intersection.x > bishop.pos.x) or (intersection.x > posOnPositiveDiagonal.x and intersection.x < bishop.pos.x) or (intersection.x == bishop.pos.x and sign(posOnPositiveDiagonal.x - intersection.x) == sign(piece.pos.x - intersection.x)):
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
				if (intersection.x < posOnNegativeDiagonal.x and intersection.x > bishop.pos.x) or (intersection.x > posOnNegativeDiagonal.x and intersection.x < bishop.pos.x) or (intersection.x == bishop.pos.x and sign(posOnNegativeDiagonal.x - intersection.x) == sign(piece.pos.x - intersection.x)):
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
				if (intersection.y < posOnVertical.y and intersection.y > rook.pos.y) or (intersection.y > posOnVertical.y and intersection.y < rook.pos.y) or (intersection.y == rook.pos.y and sign(posOnVertical.y - intersection.y) == sign(piece.pos.y - intersection.y)):
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
				if (intersection.x < posOnHorizontal.x and intersection.x > rook.pos.x) or (intersection.x > posOnHorizontal.x and intersection.x < rook.pos.x) or (intersection.x == rook.pos.x and sign(posOnHorizontal.x - intersection.x) == sign(piece.pos.x - intersection.x)):
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
	
static func closestPosKingCanMoveTo(king: Piece, pieces: Array[Piece], tryMovePos: Vector2i) -> Vector2i:
	var rookPos: Vector2i = closestPosRookCanMoveTo(king, pieces, tryMovePos)
	rookPos.x = clamp(rookPos.x, king.pos.x - (Piece.boardSize.x / 8), king.pos.x + (Piece.boardSize.x / 8))
	rookPos.y = clamp(rookPos.y, king.pos.y - (Piece.boardSize.y / 8), king.pos.y + (Piece.boardSize.y / 8))
	var bishopPos: Vector2i = closestPosBishopCanMoveTo(king, pieces, tryMovePos)
	var bishopDiff: Vector2i = bishopPos - king.pos
	if bishopDiff.x == bishopDiff.y:
		var posOnPositiveDiagonalClampedX: int = clamp(bishopPos.x, king.pos.x - (Piece.boardSize.x / 8), king.pos.x + (Piece.boardSize.x / 8))
		bishopPos.y -= bishopPos.x - posOnPositiveDiagonalClampedX
		bishopPos.x = posOnPositiveDiagonalClampedX
		var posOnPositiveDiagonalClampedY: int = clamp(bishopPos.y, king.pos.y - (Piece.boardSize.y / 8), king.pos.y + (Piece.boardSize.y / 8))
		bishopPos.x -= bishopPos.y - posOnPositiveDiagonalClampedY
		bishopPos.y = posOnPositiveDiagonalClampedY
	else:
		var posOnNegativeDiagonalClampedX: int = clamp(bishopPos.x, king.pos.x - (Piece.boardSize.x / 8), king.pos.x + (Piece.boardSize.x / 8))
		bishopPos.y += bishopPos.x - posOnNegativeDiagonalClampedX
		bishopPos.x = posOnNegativeDiagonalClampedX
		var posOnNegativeDiagonalClampedY: int = clamp(bishopPos.y, king.pos.y - (Piece.boardSize.y / 8), king.pos.y + (Piece.boardSize.y / 8))
		bishopPos.x += bishopPos.y - posOnNegativeDiagonalClampedY
		bishopPos.y = posOnNegativeDiagonalClampedY
	return bishopPos if (bishopPos - tryMovePos).length_squared() < (rookPos - tryMovePos).length_squared() else rookPos

static func closestPosCanMoveTo(piece: Piece, pieces: Array[Piece], tryMovePos: Vector2i) -> Vector2i:
	match piece.type:
		Piece.PieceType.PAWN:
			return closestPosPawnCanMoveTo(piece, pieces, tryMovePos)
		Piece.PieceType.KNIGHT:
			return closestPosKnightCanMoveTo(piece, pieces, tryMovePos)
		Piece.PieceType.BISHOP:
			return closestPosBishopCanMoveTo(piece, pieces, tryMovePos)
		Piece.PieceType.ROOK:
			return closestPosRookCanMoveTo(piece, pieces, tryMovePos)
		Piece.PieceType.QUEEN:
			return closestPosQueenCanMoveTo(piece, pieces, tryMovePos)
		_:
			return closestPosKingCanMoveTo(piece, pieces, tryMovePos)
			
static func canPieceMoveTo(piece: Piece, pieces: Array[Piece], tryMovePos: Vector2i) -> bool:
	return closestPosCanMoveTo(piece, pieces, tryMovePos) == tryMovePos
