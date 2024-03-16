float lineBlur(vec2 start, vec2 end, vec2 point, float blur) { //blurs the left of the directed line from start to end
	float signedDist = ((end.x-start.x)*(start.y-point.y) - (start.x-point.x)*(end.y-start.y)) / distance(start, end);
	if(signedDist <= 0.) {
		return 1.;
	}
	if(signedDist <= blur) {
		return 1. - (signedDist / blur);
	}
	return 0.;
}