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

static func diagonalLinesIntersection(pointOnPositiveSlopeLine: Vector2i, pointOnNegativeSlopeLine: Vector2i, roundToPositiveSlopeLine: bool) -> Vector2i:
	var intersectionx2: Vector2i = Vector2i(pointOnPositiveSlopeLine.x - pointOnPositiveSlopeLine.y + pointOnNegativeSlopeLine.x + pointOnNegativeSlopeLine.y,
											pointOnPositiveSlopeLine.y - pointOnPositiveSlopeLine.x + pointOnNegativeSlopeLine.x + pointOnNegativeSlopeLine.y)
	
	if intersectionx2.x % 2 == 1:
		if roundToPositiveSlopeLine:
			intersectionx2.x += 1
			intersectionx2.y += 1
		else:
			intersectionx2.x += 1
			intersectionx2.y -= 1
	
	return Vector2i(intersectionx2.x / 2, intersectionx2.y / 2)
