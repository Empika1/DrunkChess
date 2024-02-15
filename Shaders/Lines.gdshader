shader_type canvas_item;

uniform vec2[128] lineStarts;
uniform vec2[128] lineEnds;
uniform vec2 lineStart;
uniform vec2 lineEnd;
uniform float thickness;
uniform float blur;

float l2(vec2 vec) {
	return vec.x * vec.x + vec.y * vec.y;
}

float dot(vec2 a, vec2 b) {
	return a.x * b.x + a.y * b.y;
}

void fragment() {
	vec2 a = lineStart;
	vec2 b = lineEnd;
	vec2 c = UV;
	float t = thickness;
	
	float val = (a.x-c.x) * (a.x-b.x) + (a.y-c.y) * (a.y-b.y);
	float v1 = l2(a-b) * l2(a-c);
	float v2 = t*t * l2(a-b) + pow((a.x-c.x)*(a.x-b.x) + (a.y-c.y)*(a.y-b.y), 2);
	if(v1 <= v2) {
		COLOR = vec4(1.);
	}
	else if(v1 <= v2 + (blur * 0.01)) {
		COLOR = vec4(1., 1., 1., 1. - (v1 - v2) / (blur * 0.01));
	}
	else {
		COLOR = vec4(0.);
	}
	/*if(0. <= val && val <= l2(a-b) && v1 <= v2) {
		COLOR = vec4(1.);
	}
	else {
		COLOR = vec4(0.);
	}*/
}