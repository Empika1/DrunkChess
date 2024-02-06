extends RefCounted
class_name Geometry

static func ceilSqrt(val: int) -> int:
	var sqrtVal = val ** 0.5
	if sqrtVal ** 2 == val:
		return sqrtVal
	return sqrtVal + 1

func vericalLineCircleIntersections(lineX: int, circlePos: Vector2i, circleRadius: int) -> Array[Vector2i]:
	var discr: int = circleRadius ** 2 - lineX ** 2 + 2 * lineX * circlePos.x - circlePos.x ** 2
	if discr < 0: #no intersecion
		return []
	#sqrtDiscr = sqrt(discr)
	return []
