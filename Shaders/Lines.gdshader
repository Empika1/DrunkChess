shader_type canvas_item;

const int numLines = 16;
uniform vec2[numLines] lineStarts;
uniform vec2[numLines] lineEnds;
uniform vec2[numLines] lineColorsrg;
uniform vec2[numLines] lineColorsba;
uniform float[numLines] lineThicknesses;

float l2(vec2 vec) {
	return vec.x * vec.x + vec.y * vec.y;
}

void fragment() {
	float blur = 0.0002;
	
	COLOR = vec4(0.);
	for(int i = 0; i < numLines; i++)
	{
		vec4 col = vec4(lineColorsrg[i].xy, lineColorsba[i].xy);
		if(col.a == 0.)
			break;
		vec2 a = lineStarts[i];
		vec2 b = lineEnds[i];
		vec2 c = UV;
		float t = lineThicknesses[i];
		
		float val = (a.x-c.x) * (a.x-b.x) + (a.y-c.y) * (a.y-b.y);
		float v1 = l2(a-b) * l2(a-c);
		float v2 = t*t * l2(a-b) + pow((a.x-c.x)*(a.x-b.x) + (a.y-c.y)*(a.y-b.y), 2);
		float v3 = (t+blur)*(t+blur) * l2(a-b) + pow((a.x-c.x)*(a.x-b.x) + (a.y-c.y)*(a.y-b.y), 2);
		if(v1 <= v2) {
			col.a *= 1.;
		}
		else if(v1 <= v3) {
			col.a *= 1. - (v1 - v2) / (v3 - v2);
		}
		else {
			col.a *= 0.;
		}
		if(0. <= val && val <= l2(a-b)) {
			col.a *= 1.;
		}
		else {
			col.a *= 0.;
		}
		COLOR += col;
	}
}