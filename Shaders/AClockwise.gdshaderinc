bool aClockwise(vec2 a, vec2 b) {
	return a.x * b.y > a.y * b.x;
}