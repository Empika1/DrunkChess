extends RefCounted
class_name Geometry

static func ceilSqrt(val: int) -> int:
	var sqrtVal: float = val ** 0.5
	var roundSqrtVal: int = round(sqrtVal)
	if roundSqrtVal ** 2 >= val:
		return roundSqrtVal
	return roundSqrtVal + 1

static func floorSqrt(val: int) -> int:
	var sqrtVal: float = val ** 0.5
	var roundSqrtVal: int = round(sqrtVal)
	if roundSqrtVal ** 2 <= val:
		return roundSqrtVal
	return roundSqrtVal - 1

static func verticalLineCircleIntersections(lineX: int, circlePos: Vector2i, circleRadius: int, outside: bool = true) -> Array[Vector2i]:
	var discr: int = circleRadius ** 2 - lineX ** 2 + 2 * lineX * circlePos.x - circlePos.x ** 2
	if discr < 0: #no intersecion
		return []
	if discr == 0: #one intersection
		return [Vector2i(lineX, circlePos.y)]
	var sqrtDiscr = ceilSqrt(discr) if outside else floorSqrt(discr) #two intersections
	return [Vector2i(lineX, circlePos.y + sqrtDiscr), Vector2i(lineX, circlePos.y - sqrtDiscr)]

static func horizontalLineCircleIntersections(lineY: int, circlePos: Vector2i, circleRadius: int, outside: bool = true) -> Array[Vector2i]:
	var discr: int = circleRadius ** 2 - lineY ** 2 + 2 * lineY * circlePos.y - circlePos.y ** 2
	if discr < 0: #no intersecion
		return []
	if discr == 0: #one intersection
		return [Vector2i(circlePos.x, lineY)]
	var sqrtDiscr = ceilSqrt(discr) if outside else floorSqrt(discr) #two intersections
	return [Vector2i(circlePos.x + sqrtDiscr, lineY), Vector2i(circlePos.x - sqrtDiscr, lineY)]

static func positiveDiagonalLineCircleIntersections(lineYIntercept: int, circlePos: Vector2i, circleRadius: int, outside: bool = true) -> Array[Vector2i]:
	var discr: int = 2 * circleRadius ** 2 + 2 * circlePos.x * circlePos.y + 2 * lineYIntercept * circlePos.y - circlePos.x ** 2 - 2 * circlePos.x * lineYIntercept - lineYIntercept ** 2 - circlePos.y ** 2
	if discr < 0: #no intersecion
		return []
	#discr can not be 0 because of the irrationality of sqrt(2), therefore here discr > 0
	var nonDiscr: int = circlePos.x - lineYIntercept + circlePos.y
	#return [Vector2i(nonDiscr/2, nonDiscr/2 + lineYIntercept)]
	var sqrtDiscr: int = ceilSqrt(discr) if outside else floorSqrt(discr)
	var twoX1: int = nonDiscr + sqrtDiscr
	var twoX2: int = nonDiscr - sqrtDiscr
	if twoX1 % 2 == 1:
		if outside:
			twoX1 += 1
			twoX2 -= 1
		else:
			twoX1 -= 1
			twoX2 += 1
	var x1: int = twoX1 / 2
	var x2: int = twoX2 / 2
	
	var v1: Vector2i = Vector2i(x1, x1 + lineYIntercept)
	var v2: Vector2i = Vector2i(x2, x2 + lineYIntercept)

	if v1 == v2:
		return [v1]
	return [v1, v2]

static func negativeDiagonalLineCircleIntersections(lineYIntercept: int, circlePos: Vector2i, circleRadius: int, outside: bool = true) -> Array[Vector2i]:
	var discr: int = 2 * circleRadius ** 2 + 2 * circlePos.x * lineYIntercept + 2 * lineYIntercept * circlePos.y - circlePos.x ** 2 - 2 * circlePos.x * circlePos.y - lineYIntercept ** 2 - circlePos.y ** 2
	if discr < 0: #no intersecion
		return []
	#discr can not be 0 because of the irrationality of sqrt(2), therefore here discr > 0
	var nonDiscr: int = circlePos.x + lineYIntercept - circlePos.y
	#return [Vector2i(nonDiscr/2, nonDiscr/2 + lineYIntercept)]
	var sqrtDiscr: int = ceilSqrt(discr) if outside else floorSqrt(discr)
	var twoX1: int = nonDiscr + sqrtDiscr
	var twoX2: int = nonDiscr - sqrtDiscr
	if twoX1 % 2 == 1:
		if outside:
			twoX1 += 1
			twoX2 -= 1
		else:
			twoX1 -= 1
			twoX2 += 1
	var x1: int = twoX1 / 2
	var x2: int = twoX2 / 2
	
	var v1: Vector2i = Vector2i(x1, -x1 + lineYIntercept)
	var v2: Vector2i = Vector2(x2, -x2 + lineYIntercept)

	if v1 == v2:
		return [v1]
	return [v1, v2]

static func diagonalLinesIntersection(pointOnPositiveSlopeLine: Vector2i, pointOnNegativeSlopeLine: Vector2i, roundToPositiveSlopeLine: bool, towardsPoint: bool) -> Vector2i:
	var intersectionx2: Vector2i = Vector2i(pointOnPositiveSlopeLine.x - pointOnPositiveSlopeLine.y + pointOnNegativeSlopeLine.x + pointOnNegativeSlopeLine.y,
											pointOnPositiveSlopeLine.y - pointOnPositiveSlopeLine.x + pointOnNegativeSlopeLine.x + pointOnNegativeSlopeLine.y)
	
	if intersectionx2.x % 2 == 1:
		if roundToPositiveSlopeLine:
			if (pointOnPositiveSlopeLine.x * 2 < intersectionx2.x) == towardsPoint:
				intersectionx2.x -= 1
				intersectionx2.y -= 1
			else:
				intersectionx2.x += 1
				intersectionx2.y += 1
		else:
			if (pointOnPositiveSlopeLine.x * 2 < intersectionx2.x) == towardsPoint:
				intersectionx2.x += 1
				intersectionx2.y -= 1
			else:
				intersectionx2.x -= 1
				intersectionx2.y += 1
	
	return Vector2i(intersectionx2.x / 2, intersectionx2.y / 2)

static func positiveDiagonalLineVerticalLineIntersection(pointOnPositiveSlopeLine: Vector2i, verticalLineX: int) -> Vector2i:
	return Vector2i(verticalLineX, verticalLineX + pointOnPositiveSlopeLine.y - pointOnPositiveSlopeLine.x)
	
static func positiveDiagonalLineHorizontalLineIntersection(pointOnPositiveSlopeLine: Vector2i, horizontalLineY: int) -> Vector2i:
	return Vector2i(horizontalLineY + pointOnPositiveSlopeLine.x - pointOnPositiveSlopeLine.y, horizontalLineY)

static func negativeDiagonalLineVerticalLineIntersection(pointOnNegativeSlopeLine: Vector2i, verticalLineX: int) -> Vector2i:
	return Vector2i(verticalLineX, -verticalLineX + pointOnNegativeSlopeLine.y + pointOnNegativeSlopeLine.x)

static func negativeDiagonalLineHorizontalLineIntersection(pointOnNegativeSlopeLine: Vector2i, horizontalLineY: int) -> Vector2i:
	return Vector2i(-horizontalLineY + pointOnNegativeSlopeLine.y + pointOnNegativeSlopeLine.x, horizontalLineY)

static func circlesIntersection(pos1: Vector2i, radius1: int, pos2: Vector2i, radius2: int) -> Array[Vector2]:
	var x1: float = float(pos1.x)
	var y1: float = float(pos1.y)
	var r1: float = float(radius1)
	var x2: float = float(pos2.x)
	var y2: float = float(pos2.y)
	var r2: float = float(radius2)
	
	var centerdx: float = x1 - x2
	var centerdy: float = y1 - y2
	var R: float = sqrt(centerdx ** 2 + centerdy ** 2)
	if !(absf(r1 - r2) <= R && R <= r1 + r2):
		return []
	
	var R2: float = centerdx ** 2 + centerdy ** 2
	var R4: float = R2 ** 2
	var a: float = (r1 ** 2 - r2 ** 2) / (2 * R2)
	var r2r2: float = r1 ** 2 - r2 ** 2
	var c = sqrt(2 * (r1 ** 2 + r2 ** 2) / R2 - (r2r2 ** 2) / R4 - 1)
	
	var fx = (x1 + x2) / 2 + a * (x2 - x1)
	var gx = c * (y2 - y1) / 2
	var ix1 = fx + gx
	var ix2 = fx - gx
	
	var fy = (y1 + y2) / 2 + a * (y2 - y1)
	var gy = c * (x1 - x2) / 2
	var iy1 = fy + gy
	var iy2 = fy - gy
	
	var intersection1 = Vector2(ix1, iy1)
	var intersection2 = Vector2(ix2, iy2)
	if intersection1 == intersection2:
		return [intersection1]
	return [intersection1, intersection2]

static func nextPointOnSpiral(point: Vector2i) -> Vector2i:
	if point.y <= point.x - 1 and point.y > -point.x:
		return Vector2i(point.x, point.y - 1)
	if point.y <= -point.x and point.y < point.x:
		return Vector2i(point.x - 1, point.y)
	if point.y >= point.x and point.y < -point.x:
		return Vector2(point.x, point.y + 1)
	return Vector2(point.x + 1, point.y)
	
static func spiralizePoint(point: Vector2i, predicate: Callable) -> Vector2i:
	var spiralPos: Vector2i = Vector2i(0, 0)
	while !predicate.call(point + spiralPos):
		spiralPos = nextPointOnSpiral(spiralPos)
	return point + spiralPos

static func isOnCircle(circlePos: Vector2i, circleRadius: int, testPos: Vector2i) -> bool:
	return floorSqrt((testPos - circlePos).length_squared()) == circleRadius

static func circlesIntersectionInt(pos1: Vector2i, radius1: int, pos2: Vector2i, radius2: int, inside: bool) -> Array[Vector2i]:
	var unroundedIntersections: Array[Vector2] = circlesIntersection(pos1, radius1, pos2, radius2)
	var roundedIntersections: Array[Vector2i] = []
	for intersection: Vector2 in unroundedIntersections:
		var roundedIntersection: Vector2i = Vector2i(roundi(intersection.x), roundi(intersection.y))
		var spiralPos: Vector2i = Vector2i(0, 0)
		while !(isOnCircle(pos1, radius1, roundedIntersection + spiralPos) and (pos2 - (roundedIntersection + spiralPos)).length_squared() <= radius2 ** 2 if inside else (pos2 - (roundedIntersection + spiralPos)).length_squared() >= radius2 ** 2):
			spiralPos = nextPointOnSpiral(spiralPos)
		roundedIntersections.append(roundedIntersection + spiralPos)
	return roundedIntersections

static func acbOrientation(a: Vector2i, b: Vector2i, c: Vector2i) -> int: #returns 1 if a is clockwise from b, -1 if counterclockwise, and 0 if equal
	var ar: Vector2i = a - c
	var br: Vector2i = b - c
	return signi(br.x * ar.y - ar.x * br.y)
