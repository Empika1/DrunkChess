extends RefCounted
class_name PieceLogic

static func doPiecesOverlap(pos1: Vector2i, radius1: int, pos2: Vector2i, radius2: int) -> bool:
	return (pos1 - pos2).length_squared() < (radius1 + radius2) ** 2

static func isPieceOutsideBoard(pos: Vector2i, radius: int, maxPos: Vector2i) -> bool:
	return pos.x - radius < 0 or pos.y - radius < 0 or pos.x + radius > maxPos.x or pos.y + radius > maxPos.y

class PieceMovePoints:
	var pieceType: Piece.PieceType

class PawnMovePoints extends PieceMovePoints:
	var verticalLowerBound: Vector2i #verticalLowerBound.y <= verticalUpperBound.y
	var verticalUpperBound: Vector2i
	var positiveDiagonalLowerBound: Vector2i #positiveDiagonalLowerBound.x <= positiveDiagonalUpperBound.x
	var positiveDiagonalUpperBound: Vector2i 
	var negativeDiagonalLowerBound: Vector2i #negativeDiagonalLowerBound.x <= negativeDiagonalUpperBound.x
	var negativeDiagonalUpperBound: Vector2i
	func _init(verticalLowerBound_: Vector2i, verticalUpperBound_: Vector2i, positiveDiagonalLowerBound_: Vector2i, positiveDiagonalUpperBound_: Vector2i, negativeDiagonalLowerBound_: Vector2i, negativeDiagonalUpperBound_: Vector2i):
		pieceType = Piece.PieceType.PAWN
		verticalLowerBound = verticalLowerBound_
		verticalUpperBound = verticalUpperBound_
		positiveDiagonalLowerBound = positiveDiagonalLowerBound_
		positiveDiagonalUpperBound = positiveDiagonalUpperBound_
		negativeDiagonalLowerBound = negativeDiagonalLowerBound_
		negativeDiagonalUpperBound = negativeDiagonalUpperBound_

static func calculatePawnMovePoints(pawn: Piece, pieces: Array[Piece]) -> PawnMovePoints:
	var verticalLowerBound: Vector2i
	var verticalUpperBound: Vector2i
	
	var moveLength: int = Piece.boardSize.y / 8
	if !pawn.hasMoved:
		moveLength *= 2
	if pawn.color == Piece.PieceColor.WHITE:
		verticalLowerBound = Vector2i(pawn.pos.x, maxi(pawn.pos.y - moveLength, pawn.hitRadius))
		verticalUpperBound = pawn.pos
	else:
		verticalLowerBound = pawn.pos
		verticalUpperBound = Vector2i(pawn.pos.x, mini(pawn.pos.y + moveLength, Piece.maxPos.y - pawn.hitRadius))
	
	for piece: Piece in pieces:
		if piece.valueEquals(pawn):
			continue
		
		var intersections: Array[Vector2i] = Geometry.verticalLineCircleIntersections(pawn.pos.x, piece.pos, piece.hitRadius + pawn.hitRadius)
		for intersection: Vector2i in intersections:
			if pawn.color == Piece.PieceColor.WHITE:
				if intersection.y <= pawn.pos.y:
					verticalLowerBound.y = maxi(verticalLowerBound.y, intersection.y)
			else:
				if intersection.y >= pawn.pos.y:
					verticalUpperBound.y = mini(verticalUpperBound.y, intersection.y)
		
	var positiveDiagonalLowerBound: Vector2i
	var positiveDiagonalUpperBound: Vector2i
	var negativeDiagonalLowerBound: Vector2i
	var negativeDiagonalUpperBound: Vector2i
	if pawn.color == Piece.PieceColor.WHITE:
		var positiveDiagonalLowerBoundX: int = maxi(maxi(Piece.hitRadius, pawn.pos.x - Piece.squareSize.x), Piece.hitRadius - pawn.pos.y + pawn.pos.x)
		var positiveDiagonalUpperBoundX: int = pawn.pos.x
		var positiveDiagonalLowerBoundCaptureX: int = 0
		var positiveDiagonalUpperBoundCaptureX: int = 0
		var capturingPieceOnPositiveDiagonal: bool = false
		for piece: Piece in pieces:
			if piece.valueEquals(pawn):
				continue
		
			var intersections: Array[Vector2i]
			if piece.color == pawn.color:
				intersections = Geometry.positiveDiagonalLineCircleIntersections(pawn.pos.y - pawn.pos.x, piece.pos, piece.hitRadius + pawn.hitRadius, true)
				if intersections.size() == 0:
					continue
				var largerX: int
				if intersections.size() == 1:
					largerX = intersections[0].x
				else:
					largerX = maxi(intersections[0].x, intersections[1].x)
				if largerX <= pawn.pos.x:
					positiveDiagonalLowerBoundX = maxi(positiveDiagonalLowerBoundX, largerX)
			else:
				intersections = Geometry.positiveDiagonalLineCircleIntersections(pawn.pos.y - pawn.pos.x, piece.pos, piece.hitRadius + pawn.hitRadius, false)
				if intersections.size() == 0:
					continue
				var largerX: int
				if intersections.size() == 1:
					largerX = intersections[0].x
				else:
					largerX = maxi(intersections[0].x, intersections[1].x)
				if largerX <= pawn.pos.x and largerX >= positiveDiagonalUpperBoundCaptureX:
					positiveDiagonalLowerBoundCaptureX = Geometry.diagonalLinesIntersection(pawn.pos, piece.pos, true, true).x
					positiveDiagonalUpperBoundCaptureX = largerX
					capturingPieceOnPositiveDiagonal = true
		var positiveDiagonalLowerX: int
		var positiveDiagonalUpperX: int
		if !capturingPieceOnPositiveDiagonal or mini(positiveDiagonalUpperBoundX, positiveDiagonalUpperBoundCaptureX) < maxi(positiveDiagonalLowerBoundX, positiveDiagonalLowerBoundCaptureX):
			positiveDiagonalLowerX = pawn.pos.x
			positiveDiagonalUpperX = pawn.pos.x
		else:
			positiveDiagonalLowerX = maxi(positiveDiagonalLowerBoundX, positiveDiagonalLowerBoundCaptureX)
			positiveDiagonalUpperX = mini(positiveDiagonalUpperBoundX, positiveDiagonalUpperBoundCaptureX)
		positiveDiagonalLowerBound = Vector2i(positiveDiagonalLowerX, positiveDiagonalLowerX - pawn.pos.x + pawn.pos.y)
		positiveDiagonalUpperBound = Vector2i(positiveDiagonalUpperX, positiveDiagonalUpperX - pawn.pos.x + pawn.pos.y)
		
		var negativeDiagonalLowerBoundX: int = pawn.pos.x
		var negativeDiagonalUpperBoundX: int = mini(mini(Piece.maxPos.x - Piece.hitRadius, pawn.pos.x + Piece.squareSize.x), pawn.pos.y + pawn.pos.x - Piece.hitRadius)
		var negativeDiagonalLowerBoundCaptureX: int = Piece.maxPos.x
		var negativeDiagonalUpperBoundCaptureX: int = Piece.maxPos.x
		var capturingPieceOnNegativeDiagonal: bool = false
		for piece: Piece in pieces:
			if piece.valueEquals(pawn):
				continue
				
			var intersections: Array[Vector2i]
			if piece.color == pawn.color:
				intersections = Geometry.negativeDiagonalLineCircleIntersections(pawn.pos.y + pawn.pos.x, piece.pos, piece.hitRadius + pawn.hitRadius, true)
				if intersections.size() == 0:
					continue
				var smallerX: int
				if intersections.size() == 1:
					smallerX = intersections[0].x
				else:
					smallerX = mini(intersections[0].x, intersections[1].x)
				if smallerX >= pawn.pos.x:
					negativeDiagonalUpperBoundX = mini(negativeDiagonalUpperBoundX, smallerX)
			else:
				intersections = Geometry.negativeDiagonalLineCircleIntersections(pawn.pos.y + pawn.pos.x, piece.pos, piece.hitRadius + pawn.hitRadius, false)
				if intersections.size() == 0:
					continue
				var smallerX: int
				if intersections.size() == 1:
					smallerX = intersections[0].x
				else:
					smallerX = mini(intersections[0].x, intersections[1].x)
				if smallerX >= pawn.pos.x and smallerX <= negativeDiagonalLowerBoundCaptureX:
					negativeDiagonalUpperBoundCaptureX = Geometry.diagonalLinesIntersection(piece.pos, pawn.pos, false, true).x
					negativeDiagonalLowerBoundCaptureX = smallerX
					capturingPieceOnNegativeDiagonal = true
		var negativeDiagonalLowerX: int
		var negativeDiagonalUpperX: int
		if !capturingPieceOnNegativeDiagonal or mini(negativeDiagonalUpperBoundX, negativeDiagonalUpperBoundCaptureX) < maxi(negativeDiagonalLowerBoundX, negativeDiagonalLowerBoundCaptureX):
			negativeDiagonalLowerX = pawn.pos.x
			negativeDiagonalUpperX = pawn.pos.x
		else:
			negativeDiagonalLowerX = maxi(negativeDiagonalLowerBoundX, negativeDiagonalLowerBoundCaptureX)
			negativeDiagonalUpperX = mini(negativeDiagonalUpperBoundX, negativeDiagonalUpperBoundCaptureX)
		negativeDiagonalLowerBound = Vector2i(negativeDiagonalLowerX, pawn.pos.x - negativeDiagonalLowerX + pawn.pos.y)
		negativeDiagonalUpperBound = Vector2i(negativeDiagonalUpperX, pawn.pos.x - negativeDiagonalUpperX + pawn.pos.y)
	else:
		var positiveDiagonalLowerBoundX: int = pawn.pos.x
		var positiveDiagonalUpperBoundX: int = mini(mini(Piece.maxPos.x - Piece.hitRadius, pawn.pos.x + Piece.squareSize.x), pawn.pos.x - pawn.pos.y + Piece.maxPos.y - Piece.hitRadius)
		var positiveDiagonalLowerBoundCaptureX: int = Piece.maxPos.x
		var positiveDiagonalUpperBoundCaptureX: int = Piece.maxPos.x
		var capturingPieceOnPositiveDiagonal: bool = false
		for piece: Piece in pieces:
			if piece.valueEquals(pawn):
				continue
			
			var intersections: Array[Vector2i]
			if piece.color == pawn.color:
				intersections = Geometry.positiveDiagonalLineCircleIntersections(pawn.pos.y - pawn.pos.x, piece.pos, piece.hitRadius + pawn.hitRadius, true)
				if intersections.size() == 0:
					continue
				var smallerX: int
				if intersections.size() == 1:
					smallerX = intersections[0].x
				else:
					smallerX = mini(intersections[0].x, intersections[1].x)
				if smallerX >= pawn.pos.x:
					positiveDiagonalUpperBoundX = mini(positiveDiagonalUpperBoundX, smallerX)
			else:
				intersections = Geometry.positiveDiagonalLineCircleIntersections(pawn.pos.y - pawn.pos.x, piece.pos, piece.hitRadius + pawn.hitRadius, false)
				if intersections.size() == 0:
					continue
				var smallerX: int
				if intersections.size() == 1:
					smallerX = intersections[0].x
				else:
					smallerX = mini(intersections[0].x, intersections[1].x)
				if smallerX >= pawn.pos.x and smallerX <= positiveDiagonalLowerBoundCaptureX:
					positiveDiagonalUpperBoundCaptureX = Geometry.diagonalLinesIntersection(pawn.pos, piece.pos, true, true).x
					positiveDiagonalLowerBoundCaptureX = smallerX
					capturingPieceOnPositiveDiagonal = true
		var positiveDiagonalLowerX: int
		var positiveDiagonalUpperX: int
		if !capturingPieceOnPositiveDiagonal or mini(positiveDiagonalUpperBoundX, positiveDiagonalUpperBoundCaptureX) < maxi(positiveDiagonalLowerBoundX, positiveDiagonalLowerBoundCaptureX):
			positiveDiagonalLowerX = pawn.pos.x
			positiveDiagonalUpperX = pawn.pos.x
		else:
			positiveDiagonalLowerX = maxi(positiveDiagonalLowerBoundX, positiveDiagonalLowerBoundCaptureX)
			positiveDiagonalUpperX = mini(positiveDiagonalUpperBoundX, positiveDiagonalUpperBoundCaptureX)
		positiveDiagonalLowerBound = Vector2i(positiveDiagonalLowerX, positiveDiagonalLowerX - pawn.pos.x + pawn.pos.y)
		positiveDiagonalUpperBound = Vector2i(positiveDiagonalUpperX, positiveDiagonalUpperX - pawn.pos.x + pawn.pos.y)
		
		var negativeDiagonalLowerBoundX: int = maxi(maxi(Piece.hitRadius, pawn.pos.x - Piece.squareSize.x), pawn.pos.y + pawn.pos.x - Piece.maxPos.y + Piece.hitRadius)
		var negativeDiagonalUpperBoundX: int = pawn.pos.x
		var negativeDiagonalLowerBoundCaptureX: int = 0
		var negativeDiagonalUpperBoundCaptureX: int = 0
		var capturingPieceOnNegativeDiagonal: bool = false
		for piece: Piece in pieces:
			if piece.valueEquals(pawn):
				continue
				
			var intersections: Array[Vector2i]
			if piece.color == pawn.color:
				intersections = Geometry.negativeDiagonalLineCircleIntersections(pawn.pos.y + pawn.pos.x, piece.pos, piece.hitRadius + pawn.hitRadius, true)
				if intersections.size() == 0:
					continue
				var largerX: int
				if intersections.size() == 1:
					largerX = intersections[0].x
				else:
					largerX = maxi(intersections[0].x, intersections[1].x)
				if largerX <= pawn.pos.x:
					negativeDiagonalLowerBoundX = maxi(negativeDiagonalLowerBoundX, largerX)
			else:
				intersections = Geometry.negativeDiagonalLineCircleIntersections(pawn.pos.y + pawn.pos.x, piece.pos, piece.hitRadius + pawn.hitRadius, false)
				if intersections.size() == 0:
					continue
				var largerX: int
				if intersections.size() == 1:
					largerX = intersections[0].x
				else:
					largerX = maxi(intersections[0].x, intersections[1].x)
				if largerX <= pawn.pos.x and largerX >= negativeDiagonalUpperBoundCaptureX:
					negativeDiagonalLowerBoundCaptureX = Geometry.diagonalLinesIntersection(piece.pos, pawn.pos, false, true).x
					negativeDiagonalUpperBoundCaptureX = largerX
					capturingPieceOnNegativeDiagonal = true
		var negativeDiagonalLowerX: int
		var negativeDiagonalUpperX: int
		if !capturingPieceOnNegativeDiagonal or mini(negativeDiagonalUpperBoundX, negativeDiagonalUpperBoundCaptureX) < maxi(negativeDiagonalLowerBoundX, negativeDiagonalLowerBoundCaptureX):
			negativeDiagonalLowerX = pawn.pos.x
			negativeDiagonalUpperX = pawn.pos.x
		else:
			negativeDiagonalLowerX = maxi(negativeDiagonalLowerBoundX, negativeDiagonalLowerBoundCaptureX)
			negativeDiagonalUpperX = mini(negativeDiagonalUpperBoundX, negativeDiagonalUpperBoundCaptureX)
		negativeDiagonalLowerBound = Vector2i(negativeDiagonalLowerX, pawn.pos.x - negativeDiagonalLowerX + pawn.pos.y)
		negativeDiagonalUpperBound = Vector2i(negativeDiagonalUpperX, pawn.pos.x - negativeDiagonalUpperX + pawn.pos.y)
	
	return PawnMovePoints.new(verticalLowerBound, verticalUpperBound, positiveDiagonalLowerBound, positiveDiagonalUpperBound, negativeDiagonalLowerBound, negativeDiagonalUpperBound)

static func closestPosPawnCanMoveTo(pawn: Piece, pieces: Array[Piece], tryMovePos: Vector2i, movePoints: PawnMovePoints = null) -> Vector2i:
	var posOnVertical: Vector2i = Vector2i(pawn.pos.x, tryMovePos.y)
	var posOnPositiveDiagonal: Vector2i = Geometry.diagonalLinesIntersection(pawn.pos, tryMovePos, true, true)
	var posOnNegativeDiagonal: Vector2i = Geometry.diagonalLinesIntersection(tryMovePos, pawn.pos, false, true)

	if movePoints == null:
		movePoints = calculatePawnMovePoints(pawn, pieces)
	
	posOnVertical.y = clampi(posOnVertical.y, movePoints.verticalLowerBound.y, movePoints.verticalUpperBound.y)
	var positiveDiagonalX: int = clampi(posOnPositiveDiagonal.x, movePoints.positiveDiagonalLowerBound.x, movePoints.positiveDiagonalUpperBound.x)
	posOnPositiveDiagonal = Vector2i(positiveDiagonalX, posOnPositiveDiagonal.y + positiveDiagonalX - posOnPositiveDiagonal.x)
	var negativeDiagonalX: int = clampi(posOnNegativeDiagonal.x, movePoints.negativeDiagonalLowerBound.x, movePoints.negativeDiagonalUpperBound.x)
	posOnNegativeDiagonal = Vector2i(negativeDiagonalX, posOnNegativeDiagonal.y - negativeDiagonalX + posOnNegativeDiagonal.x)
	
	var verticalDistanceSquared: int = (posOnVertical - tryMovePos).length_squared()
	var positiveDiagonalDistanceSquared: int = (posOnPositiveDiagonal - tryMovePos).length_squared()
	var negativeDiagonalDistanceSquared: int = (posOnNegativeDiagonal - tryMovePos).length_squared()
	var minDistanceSquared: int = mini(verticalDistanceSquared, mini(positiveDiagonalDistanceSquared, negativeDiagonalDistanceSquared))
	
	if minDistanceSquared == verticalDistanceSquared:
		return posOnVertical
	elif minDistanceSquared == positiveDiagonalDistanceSquared:
		return posOnPositiveDiagonal
	else:
		return posOnNegativeDiagonal

class KnightMovePoints extends PieceMovePoints:
	var arcStarts: Array[Vector2i]
	var arcEnds: Array[Vector2i]
	func _init(arcStarts_: Array[Vector2i], arcEnds_: Array[Vector2i]):
		pieceType = Piece.PieceType.KNIGHT
		arcStarts = arcStarts_
		arcEnds = arcEnds_

static func calculateKnightMovePoints(knight: Piece, pieces: Array[Piece]) -> KnightMovePoints:
	var arcStarts: Array[Vector2i] = []
	var arcEnds: Array[Vector2i] = []
	
	for piece: Piece in pieces:
		if piece.valueEquals(knight):
			continue
		if piece.color != knight.color:
			continue
		
		var intersections: Array[Vector2i] = Geometry.circlesIntersectionInt(knight.pos, Piece.knightMoveRadius, piece.pos, knight.hitRadius + piece.hitRadius, false)
		if intersections.size() == 1:
			arcStarts.append(intersections[0])
			arcEnds.append(intersections[0])
		elif intersections.size() == 2:
			var i1: Vector2i = intersections[0] - knight.pos
			var i2: Vector2i = intersections[1] - knight.pos
			if i1.x * i2.y > i2.x * i1.y: #i1 is counterclockwise from i2
				arcStarts.append(intersections[0])
				arcEnds.append(intersections[1])
			else:
				arcStarts.append(intersections[1])
				arcEnds.append(intersections[0])
		
	var topIntersections: Array[Vector2i] = Geometry.horizontalLineCircleIntersections(knight.hitRadius, knight.pos, Piece.knightMoveRadius, true)
	var topIntersectionsSnapped: Array[Vector2i] = []
	for intersection: Vector2i in topIntersections:
		topIntersectionsSnapped.append(Geometry.spiralizePoint(intersection, func(pos): return Geometry.isOnCircle(knight.pos, Piece.knightMoveRadius, pos) and pos.y >= knight.hitRadius))
	if topIntersectionsSnapped.size() == 1:
		arcStarts.append(topIntersectionsSnapped[0])
		arcEnds.append(topIntersectionsSnapped[0])
	elif topIntersectionsSnapped.size() == 2:
		if topIntersectionsSnapped[0].x > topIntersectionsSnapped[1].x:
			arcStarts.append(topIntersectionsSnapped[1])
			arcEnds.append(topIntersectionsSnapped[0])
		else:
			arcStarts.append(topIntersectionsSnapped[0])
			arcEnds.append(topIntersectionsSnapped[1])
	
	var bottomIntersections: Array[Vector2i] = Geometry.horizontalLineCircleIntersections(knight.maxPos.y - knight.hitRadius, knight.pos, Piece.knightMoveRadius, true)
	var bottomIntersectionsSnapped: Array[Vector2i] = []
	for intersection: Vector2i in bottomIntersections:
		bottomIntersectionsSnapped.append(Geometry.spiralizePoint(intersection, func(pos): return Geometry.isOnCircle(knight.pos, Piece.knightMoveRadius, pos) and pos.y <= knight.maxPos.y - knight.hitRadius))
	if bottomIntersectionsSnapped.size() == 1:
		arcStarts.append(bottomIntersectionsSnapped[0])
		arcEnds.append(bottomIntersectionsSnapped[0])
	elif bottomIntersectionsSnapped.size() == 2:
		if bottomIntersectionsSnapped[0].x < bottomIntersectionsSnapped[1].x:
			arcStarts.append(bottomIntersectionsSnapped[1])
			arcEnds.append(bottomIntersectionsSnapped[0])
		else:
			arcStarts.append(bottomIntersectionsSnapped[0])
			arcEnds.append(bottomIntersectionsSnapped[1])
			
	var leftIntersections: Array[Vector2i] = Geometry.verticalLineCircleIntersections(knight.hitRadius, knight.pos, Piece.knightMoveRadius, true)
	var leftIntersectionsSnapped: Array[Vector2i] = []
	for intersection: Vector2i in leftIntersections:
		leftIntersectionsSnapped.append(Geometry.spiralizePoint(intersection, func(pos): return Geometry.isOnCircle(knight.pos, Piece.knightMoveRadius, pos) and pos.x >= knight.hitRadius))
	if leftIntersectionsSnapped.size() == 1:
		arcStarts.append(leftIntersectionsSnapped[0])
		arcEnds.append(leftIntersectionsSnapped[0])
	elif leftIntersectionsSnapped.size() == 2:
		if leftIntersectionsSnapped[0].y < leftIntersectionsSnapped[1].y:
			arcStarts.append(leftIntersectionsSnapped[1])
			arcEnds.append(leftIntersectionsSnapped[0])
		else:
			arcStarts.append(leftIntersectionsSnapped[0])
			arcEnds.append(leftIntersectionsSnapped[1])
	
	var rightIntersections: Array[Vector2i] = Geometry.verticalLineCircleIntersections(knight.maxPos.x - knight.hitRadius, knight.pos, Piece.knightMoveRadius, true)
	var rightIntersectionsSnapped: Array[Vector2i] = []
	for intersection: Vector2i in rightIntersections:
		rightIntersectionsSnapped.append(Geometry.spiralizePoint(intersection, func(pos): return Geometry.isOnCircle(knight.pos, Piece.knightMoveRadius, pos) and pos.x <= knight.maxPos.x - knight.hitRadius))
	if rightIntersectionsSnapped.size() == 1:
		arcStarts.append(rightIntersectionsSnapped[0])
		arcEnds.append(rightIntersectionsSnapped[0])
	elif rightIntersectionsSnapped.size() == 2:
		if rightIntersectionsSnapped[0].y > rightIntersectionsSnapped[1].y:
			arcStarts.append(rightIntersectionsSnapped[1])
			arcEnds.append(rightIntersectionsSnapped[0])
		else:
			arcStarts.append(rightIntersectionsSnapped[0])
			arcEnds.append(rightIntersectionsSnapped[1])
	
	return KnightMovePoints.new(arcStarts, arcEnds)

static func closestPosKnightCanMoveTo(knight: Piece, pieces: Array[Piece], tryMovePos: Vector2i, movePoints: KnightMovePoints = null) -> Vector2i:
	var scaledPos: Vector2 = Vector2(tryMovePos - knight.pos).normalized() * Piece.knightMoveRadius
	var roundedScaledPos: Vector2i = Vector2i(roundi(scaledPos.x), roundi(scaledPos.y)) + knight.pos
	var wantedPos: Vector2i = Geometry.spiralizePoint(roundedScaledPos, func(pos): return Geometry.isOnCircle(knight.pos, Piece.knightMoveRadius, pos))
	
	if movePoints == null:
		movePoints = calculateKnightMovePoints(knight, pieces)

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
	for point in movePoints.arcStarts + movePoints.arcEnds:
		if closestValidPos != null and (tryMovePos - point).length_squared() >= (tryMovePos - closestValidPos).length_squared():
			continue
		if isKnightMovable.call(point):
			closestValidPos = point
	
	if closestValidPos == null:
		return knight.pos
	return closestValidPos

class BishopMovePoints extends PieceMovePoints:
	var positiveDiagonalLowerBound: Vector2i #positiveDiagonalLowerBound.x <= positiveDiagonalUpperBound.x
	var positiveDiagonalUpperBound: Vector2i
	var negativeDiagonalLowerBound: Vector2i #negativeDiagonalLowerBound.x <= negativeDiagonalUpperBound.x
	var negativeDiagonalUpperBound: Vector2i
	func _init(positiveDiagonalLowerBound_: Vector2i, positiveDiagonalUpperBound_: Vector2i, negativeDiagonalLowerBound_: Vector2i, negativeDiagonalUpperBound_: Vector2i):
		pieceType = Piece.PieceType.BISHOP
		positiveDiagonalLowerBound = positiveDiagonalLowerBound_
		positiveDiagonalUpperBound = positiveDiagonalUpperBound_
		negativeDiagonalLowerBound = negativeDiagonalLowerBound_
		negativeDiagonalUpperBound = negativeDiagonalUpperBound_

static func calculateBishopMovePoints(bishop: Piece, pieces: Array[Piece]) -> BishopMovePoints:
	var positiveDiagonalLowerBoundX: int = maxi(Piece.hitRadius, Piece.hitRadius - bishop.pos.y + bishop.pos.x)
	var positiveDiagonalLowerBound: Vector2i = Vector2i(positiveDiagonalLowerBoundX, bishop.pos.y - bishop.pos.x + positiveDiagonalLowerBoundX)
	var positiveDiagonalUpperBoundX: int = mini(Piece.maxPos.x - Piece.hitRadius, bishop.pos.x - bishop.pos.y + Piece.maxPos.y - Piece.hitRadius)
	var positiveDiagonalUpperBound: Vector2i = Vector2i(positiveDiagonalUpperBoundX, bishop.pos.y - bishop.pos.x + positiveDiagonalUpperBoundX)
	for piece: Piece in pieces:
		if piece.valueEquals(bishop):
			continue
		
		var intersections: Array[Vector2i] = Geometry.positiveDiagonalLineCircleIntersections(bishop.pos.y - bishop.pos.x, piece.pos, piece.hitRadius + bishop.hitRadius)
		if piece.color == bishop.color:
			for intersection: Vector2i in intersections:
				if intersection.x > positiveDiagonalLowerBound.x and intersection.x <= bishop.pos.x:
					positiveDiagonalLowerBound = intersection
				if intersection.x < positiveDiagonalUpperBound.x and intersection.x >= bishop.pos.x:
					positiveDiagonalUpperBound = intersection
		else:
			if intersections.size() > 0:
				var intersectionPos: Vector2i = Geometry.diagonalLinesIntersection(bishop.pos, piece.pos, true, true)
				if intersectionPos.x > positiveDiagonalLowerBound.x and intersectionPos.x <= bishop.pos.x:
					positiveDiagonalLowerBound = intersectionPos
				if intersectionPos.x < positiveDiagonalUpperBound.x and intersectionPos.x >= bishop.pos.x:
					positiveDiagonalUpperBound = intersectionPos
	
	var negativeDiagonalLowerBoundX: int = maxi(Piece.hitRadius, bishop.pos.y + bishop.pos.x - Piece.maxPos.y + Piece.hitRadius)
	var negativeDiagonalLowerBound: Vector2i = Vector2i(negativeDiagonalLowerBoundX, bishop.pos.y - negativeDiagonalLowerBoundX + bishop.pos.x)
	var negativeDiagonalUpperBoundX: int = mini(Piece.maxPos.x - Piece.hitRadius, bishop.pos.y + bishop.pos.x - Piece.hitRadius)
	var negativeDiagonalUpperBound: Vector2i = Vector2i(negativeDiagonalUpperBoundX, bishop.pos.y - negativeDiagonalUpperBoundX + bishop.pos.x)
	for piece: Piece in pieces:
		if piece.valueEquals(bishop):
			continue
		
		var intersections: Array[Vector2i] = Geometry.negativeDiagonalLineCircleIntersections(bishop.pos.y + bishop.pos.x, piece.pos, piece.hitRadius + bishop.hitRadius)
		if piece.color == bishop.color:
			for intersection: Vector2i in intersections:
				if intersection.x > negativeDiagonalLowerBound.x and intersection.x < bishop.pos.x:
					negativeDiagonalLowerBound = intersection
				if intersection.x < negativeDiagonalUpperBound.x and intersection.x > bishop.pos.x:
					negativeDiagonalUpperBound = intersection
		else:
			if intersections.size() > 0:
				var intersectionPos: Vector2i = Geometry.diagonalLinesIntersection(piece.pos, bishop.pos, true, true)
				if intersectionPos.x > negativeDiagonalLowerBound.x and intersectionPos.x < bishop.pos.x:
					negativeDiagonalLowerBound = intersectionPos
				if intersectionPos.x < negativeDiagonalUpperBound.x and intersectionPos.x > bishop.pos.x:
					negativeDiagonalUpperBound = intersectionPos
	
	return BishopMovePoints.new(positiveDiagonalLowerBound, positiveDiagonalUpperBound, negativeDiagonalLowerBound, negativeDiagonalUpperBound)

static func closestPosBishopCanMoveTo(bishop: Piece, pieces: Array[Piece], tryMovePos: Vector2i, movePoints: BishopMovePoints = null) -> Vector2i:
	if movePoints == null:
		movePoints = calculateBishopMovePoints(bishop, pieces)
	var posOnPositiveDiagonal = Geometry.diagonalLinesIntersection(bishop.pos, tryMovePos, true, true)
	if posOnPositiveDiagonal.x < movePoints.positiveDiagonalLowerBound.x:
		posOnPositiveDiagonal = movePoints.positiveDiagonalLowerBound
	if posOnPositiveDiagonal.x > movePoints.positiveDiagonalUpperBound.x:
		posOnPositiveDiagonal = movePoints.positiveDiagonalUpperBound
	
	var posOnNegativeDiagonal = Geometry.diagonalLinesIntersection(tryMovePos, bishop.pos, false, true)
	if posOnNegativeDiagonal.x < movePoints.negativeDiagonalLowerBound.x:
		posOnNegativeDiagonal = movePoints.negativeDiagonalLowerBound
	if posOnNegativeDiagonal.x > movePoints.negativeDiagonalUpperBound.x:
		posOnNegativeDiagonal = movePoints.negativeDiagonalUpperBound
	
	return posOnPositiveDiagonal if (posOnPositiveDiagonal - tryMovePos).length_squared() < (posOnNegativeDiagonal - tryMovePos).length_squared() else posOnNegativeDiagonal

class RookMovePoints extends PieceMovePoints:
	var verticalLowerBound: Vector2i #verticalLowerBound.y <= verticalUpperBound.y
	var verticalUpperBound: Vector2i
	var horizontalLowerBound: Vector2i #horizontalLowerBound.x <= horizontalUpperBound.x
	var horizontalUpperBound: Vector2i
	func _init(verticalLowerBound_: Vector2i, verticalUpperBound_: Vector2i, horizontalLowerBound_: Vector2i, horizontalUpperBound_: Vector2i):
		pieceType = Piece.PieceType.ROOK
		verticalLowerBound = verticalLowerBound_
		verticalUpperBound = verticalUpperBound_
		horizontalLowerBound = horizontalLowerBound_
		horizontalUpperBound = horizontalUpperBound_

static func calculateRookMovePoints(rook: Piece, pieces: Array[Piece]) -> RookMovePoints:
	var verticalLowerBound: Vector2i = Vector2i(rook.pos.x, rook.hitRadius)
	var verticalUpperBound: Vector2i = Vector2i(rook.pos.x, Piece.maxPos.y - rook.hitRadius)
	for piece: Piece in pieces:
		if piece.valueEquals(rook):
			continue
		
		var intersections: Array[Vector2i] = Geometry.verticalLineCircleIntersections(rook.pos.x, piece.pos, rook.hitRadius + piece.hitRadius, true)
		if piece.color == rook.color:
			for intersection: Vector2i in intersections:
				if intersection.y > verticalLowerBound.y and intersection.y <= rook.pos.y:
					verticalLowerBound.y = intersection.y
				if intersection.y < verticalUpperBound.y and intersection.y >= rook.pos.y:
					verticalUpperBound.y = intersection.y
		else:
			if intersections.size() > 0:
				if piece.pos.y > verticalLowerBound.y and piece.pos.y <= rook.pos.y:
					verticalLowerBound.y = piece.pos.y
				if piece.pos.y < verticalUpperBound.y and piece.pos.y >= rook.pos.y:
					verticalUpperBound.y = piece.pos.y
	
	var horizontalLowerBound: Vector2i = Vector2i(rook.hitRadius, rook.pos.y)
	var horizontalUpperBound: Vector2i = Vector2i(Piece.maxPos.x - rook.hitRadius, rook.pos.y)
	for piece: Piece in pieces:
		if piece.valueEquals(rook):
			continue
		
		var intersections: Array[Vector2i] = Geometry.horizontalLineCircleIntersections(rook.pos.y, piece.pos, rook.hitRadius + piece.hitRadius, true)
		if piece.color == rook.color:
			for intersection: Vector2i in intersections:
				if intersection.x > horizontalLowerBound.x and intersection.x <= rook.pos.x:
					horizontalLowerBound.x = intersection.x
				if intersection.x < horizontalUpperBound.x and intersection.x >= rook.pos.x:
					horizontalUpperBound.x = intersection.x
		else:
			if intersections.size() > 0:
				if piece.pos.x > horizontalLowerBound.x and piece.pos.x <= rook.pos.x:
					horizontalLowerBound.x = piece.pos.x
				if piece.pos.x < horizontalUpperBound.x and piece.pos.x >= rook.pos.x:
					horizontalUpperBound.x = piece.pos.x
	
	return RookMovePoints.new(verticalLowerBound, verticalUpperBound, horizontalLowerBound, horizontalUpperBound)

static func closestPosRookCanMoveTo(rook: Piece, pieces: Array[Piece], tryMovePos: Vector2i, movePoints: RookMovePoints = null) -> Vector2i:
	if movePoints == null:
		movePoints = calculateRookMovePoints(rook, pieces)
	var posOnVertical: Vector2i = Vector2i(rook.pos.x, tryMovePos.y)
	posOnVertical.y = clampi(posOnVertical.y, movePoints.verticalLowerBound.y, movePoints.verticalUpperBound.y)
	
	var posOnHorizontal: Vector2i = Vector2i(tryMovePos.x, rook.pos.y)
	posOnHorizontal.x = clampi(posOnHorizontal.x, movePoints.horizontalLowerBound.x, movePoints.horizontalUpperBound.x)
	
	return posOnVertical if (posOnVertical - tryMovePos).length_squared() < (posOnHorizontal - tryMovePos).length_squared() else posOnHorizontal

class QueenMovePoints extends PieceMovePoints:
	var positiveDiagonalLowerBound: Vector2i #positiveDiagonalLowerBound.x <= positiveDiagonalUpperBound.x
	var positiveDiagonalUpperBound: Vector2i
	var negativeDiagonalLowerBound: Vector2i #negativeDiagonalLowerBound.x <= negativeDiagonalUpperBound.x
	var negativeDiagonalUpperBound: Vector2i
	var verticalLowerBound: Vector2i #verticalLowerBound.y <= verticalUpperBound.y
	var verticalUpperBound: Vector2i
	var horizontalLowerBound: Vector2i #horizontalLowerBound.x <= horizontalUpperBound.x
	var horizontalUpperBound: Vector2i
	func _init(positiveDiagonalLowerBound_: Vector2i, positiveDiagonalUpperBound_: Vector2i, negativeDiagonalLowerBound_: Vector2i, negativeDiagonalUpperBound_: Vector2i, verticalLowerBound_: Vector2i, verticalUpperBound_: Vector2i, horizontalLowerBound_: Vector2i, horizontalUpperBound_: Vector2i):
		pieceType = Piece.PieceType.QUEEN
		positiveDiagonalLowerBound = positiveDiagonalLowerBound_
		positiveDiagonalUpperBound = positiveDiagonalUpperBound_
		negativeDiagonalLowerBound = negativeDiagonalLowerBound_
		negativeDiagonalUpperBound = negativeDiagonalUpperBound_
		verticalLowerBound = verticalLowerBound_
		verticalUpperBound = verticalUpperBound_
		horizontalLowerBound = horizontalLowerBound_
		horizontalUpperBound = horizontalUpperBound_

static func calculateQueenMovePoints(queen: Piece, pieces: Array[Piece]):
	var bishopPoints: BishopMovePoints = calculateBishopMovePoints(queen, pieces)
	var rookPoints: RookMovePoints = calculateRookMovePoints(queen, pieces)
	return QueenMovePoints.new(bishopPoints.positiveDiagonalLowerBound, bishopPoints.positiveDiagonalUpperBound, 
							   bishopPoints.negativeDiagonalLowerBound, bishopPoints.negativeDiagonalUpperBound,
							   rookPoints.verticalLowerBound, rookPoints.verticalUpperBound,
							   rookPoints.horizontalLowerBound, rookPoints.horizontalUpperBound)

static func closestPosQueenCanMoveTo(queen: Piece, pieces: Array[Piece], tryMovePos: Vector2i, movePoints: QueenMovePoints = null) -> Vector2i:
	if movePoints == null:
		movePoints = calculateQueenMovePoints(queen, pieces)
	var posOnPositiveDiagonal = Geometry.diagonalLinesIntersection(queen.pos, tryMovePos, true, true)
	if posOnPositiveDiagonal.x < movePoints.positiveDiagonalLowerBound.x:
		posOnPositiveDiagonal = movePoints.positiveDiagonalLowerBound
	if posOnPositiveDiagonal.x > movePoints.positiveDiagonalUpperBound.x:
		posOnPositiveDiagonal = movePoints.positiveDiagonalUpperBound
	
	var posOnNegativeDiagonal = Geometry.diagonalLinesIntersection(tryMovePos, queen.pos, false, true)
	if posOnNegativeDiagonal.x < movePoints.negativeDiagonalLowerBound.x:
		posOnNegativeDiagonal = movePoints.negativeDiagonalLowerBound
	if posOnNegativeDiagonal.x > movePoints.negativeDiagonalUpperBound.x:
		posOnNegativeDiagonal = movePoints.negativeDiagonalUpperBound
	
	var posOnVertical: Vector2i = Vector2i(queen.pos.x, tryMovePos.y)
	posOnVertical.y = clampi(posOnVertical.y, movePoints.verticalLowerBound.y, movePoints.verticalUpperBound.y)
	
	var posOnHorizontal: Vector2i = Vector2i(tryMovePos.x, queen.pos.y)
	posOnHorizontal.x = clampi(posOnHorizontal.x, movePoints.horizontalLowerBound.x, movePoints.horizontalUpperBound.x)
	
	var positiveDiagonalDistanceSquared: int = (posOnPositiveDiagonal - tryMovePos).length_squared()
	var negativeDiagonalDistanceSquared: int = (posOnNegativeDiagonal - tryMovePos).length_squared()
	var verticalDistanceSquared: int = (posOnVertical - tryMovePos).length_squared()
	var horizontalDistanceSquared: int = (posOnHorizontal - tryMovePos).length_squared()
	var minDistanceSquared: int = mini(positiveDiagonalDistanceSquared, mini(negativeDiagonalDistanceSquared, mini(verticalDistanceSquared, horizontalDistanceSquared)))
	if minDistanceSquared == positiveDiagonalDistanceSquared:
		return posOnPositiveDiagonal
	if minDistanceSquared == negativeDiagonalDistanceSquared:
		return posOnNegativeDiagonal
	if minDistanceSquared == verticalDistanceSquared:
		return posOnVertical
	return posOnHorizontal

class KingMovePoints extends PieceMovePoints:
	var positiveDiagonalLowerBound: Vector2i #positiveDiagonalLowerBound.x <= positiveDiagonalUpperBound.x
	var positiveDiagonalUpperBound: Vector2i
	var negativeDiagonalLowerBound: Vector2i #negativeDiagonalLowerBound.x <= negativeDiagonalUpperBound.x
	var negativeDiagonalUpperBound: Vector2i
	var verticalLowerBound: Vector2i #verticalLowerBound.y <= verticalUpperBound.y
	var verticalUpperBound: Vector2i
	var horizontalLowerBound: Vector2i #horizontalLowerBound.x <= horizontalUpperBound.x
	var horizontalUpperBound: Vector2i
	func _init(positiveDiagonalLowerBound_: Vector2i, positiveDiagonalUpperBound_: Vector2i, negativeDiagonalLowerBound_: Vector2i, negativeDiagonalUpperBound_: Vector2i, verticalLowerBound_: Vector2i, verticalUpperBound_: Vector2i, horizontalLowerBound_: Vector2i, horizontalUpperBound_: Vector2i):
		pieceType = Piece.PieceType.KING
		positiveDiagonalLowerBound = positiveDiagonalLowerBound_
		positiveDiagonalUpperBound = positiveDiagonalUpperBound_
		negativeDiagonalLowerBound = negativeDiagonalLowerBound_
		negativeDiagonalUpperBound = negativeDiagonalUpperBound_
		verticalLowerBound = verticalLowerBound_
		verticalUpperBound = verticalUpperBound_
		horizontalLowerBound = horizontalLowerBound_
		horizontalUpperBound = horizontalUpperBound_

static func calculateKingMovePoints(king: Piece, pieces: Array[Piece]) -> KingMovePoints:
	var bishopPoints: BishopMovePoints = calculateBishopMovePoints(king, pieces)
	var rookPoints: RookMovePoints = calculateRookMovePoints(king, pieces)
	
	var positiveDiagonalLowerBoundX: int = maxi(bishopPoints.positiveDiagonalLowerBound.x, king.pos.x - (king.boardSize.x / 8))
	bishopPoints.positiveDiagonalLowerBound = Vector2i(positiveDiagonalLowerBoundX, king.pos.y - king.pos.x + positiveDiagonalLowerBoundX)
	var positiveDiagonalUpperBoundX: int = mini(bishopPoints.positiveDiagonalUpperBound.x, king.pos.x + (king.boardSize.x / 8))
	bishopPoints.positiveDiagonalUpperBound = Vector2i(positiveDiagonalUpperBoundX, king.pos.y - king.pos.x + positiveDiagonalUpperBoundX)
	var negativeDiagonalLowerBoundX: int = maxi(bishopPoints.negativeDiagonalLowerBound.x, king.pos.x - (king.boardSize.x / 8))
	bishopPoints.negativeDiagonalLowerBound = Vector2i(negativeDiagonalLowerBoundX, king.pos.y - negativeDiagonalLowerBoundX + king.pos.x)
	var negativeDiagonalUpperBoundX: int = mini(bishopPoints.negativeDiagonalUpperBound.x, king.pos.x + (king.boardSize.x / 8))
	bishopPoints.negativeDiagonalUpperBound = Vector2i(negativeDiagonalUpperBoundX, king.pos.y - negativeDiagonalUpperBoundX + king.pos.x)
	
	rookPoints.verticalLowerBound.y = maxi(rookPoints.verticalLowerBound.y, king.pos.y - (king.boardSize.y / 8))
	rookPoints.verticalUpperBound.y = maxi(rookPoints.verticalUpperBound.y, king.pos.y + (king.boardSize.y / 8))
	rookPoints.horizontalLowerBound.x = maxi(rookPoints.horizontalLowerBound.x, king.pos.x - (king.boardSize.x / 8))
	rookPoints.horizontalUpperBound.x = maxi(rookPoints.horizontalUpperBound.x, king.pos.x + (king.boardSize.x / 8))
	
	return KingMovePoints.new(bishopPoints.positiveDiagonalLowerBound, bishopPoints.positiveDiagonalUpperBound, 
							  bishopPoints.negativeDiagonalLowerBound, bishopPoints.negativeDiagonalUpperBound,
							  rookPoints.verticalLowerBound, rookPoints.verticalUpperBound,
							  rookPoints.horizontalLowerBound, rookPoints.horizontalUpperBound)

static func closestPosKingCanMoveTo(king: Piece, pieces: Array[Piece], tryMovePos: Vector2i, movePoints: KingMovePoints = null) -> Vector2i:
	if movePoints == null:
		movePoints = calculateKingMovePoints(king, pieces)
	var posOnPositiveDiagonal = Geometry.diagonalLinesIntersection(king.pos, tryMovePos, true, true)
	if posOnPositiveDiagonal.x < movePoints.positiveDiagonalLowerBound.x:
		posOnPositiveDiagonal = movePoints.positiveDiagonalLowerBound
	if posOnPositiveDiagonal.x > movePoints.positiveDiagonalUpperBound.x:
		posOnPositiveDiagonal = movePoints.positiveDiagonalUpperBound
	
	var posOnNegativeDiagonal = Geometry.diagonalLinesIntersection(tryMovePos, king.pos, false, true)
	if posOnNegativeDiagonal.x < movePoints.negativeDiagonalLowerBound.x:
		posOnNegativeDiagonal = movePoints.negativeDiagonalLowerBound
	if posOnNegativeDiagonal.x > movePoints.negativeDiagonalUpperBound.x:
		posOnNegativeDiagonal = movePoints.negativeDiagonalUpperBound
	
	var posOnVertical: Vector2i = Vector2i(king.pos.x, tryMovePos.y)
	posOnVertical.y = clampi(posOnVertical.y, movePoints.verticalLowerBound.y, movePoints.verticalUpperBound.y)
	
	var posOnHorizontal: Vector2i = Vector2i(tryMovePos.x, king.pos.y)
	posOnHorizontal.x = clampi(posOnHorizontal.x, movePoints.horizontalLowerBound.x, movePoints.horizontalUpperBound.x)
	
	var positiveDiagonalDistanceSquared: int = (posOnPositiveDiagonal - tryMovePos).length_squared()
	var negativeDiagonalDistanceSquared: int = (posOnNegativeDiagonal - tryMovePos).length_squared()
	var verticalDistanceSquared: int = (posOnVertical - tryMovePos).length_squared()
	var horizontalDistanceSquared: int = (posOnHorizontal - tryMovePos).length_squared()
	var minDistanceSquared: int = mini(positiveDiagonalDistanceSquared, mini(negativeDiagonalDistanceSquared, mini(verticalDistanceSquared, horizontalDistanceSquared)))
	if minDistanceSquared == positiveDiagonalDistanceSquared:
		return posOnPositiveDiagonal
	if minDistanceSquared == negativeDiagonalDistanceSquared:
		return posOnNegativeDiagonal
	if minDistanceSquared == verticalDistanceSquared:
		return posOnVertical
	return posOnHorizontal

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
