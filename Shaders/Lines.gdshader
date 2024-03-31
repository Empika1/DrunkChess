shader_type canvas_item;
#include "LineBlur.gdshaderinc"
#include "Constants.gdshaderinc"

const int numlines = 16;
uniform vec2[numlines] lineStarts;
uniform vec2[numlines] lineEnds;
uniform vec2[numlines] lineColorsrg;
uniform vec2[numlines] lineColorsba;
uniform float[numlines] lineThicknesses;

varying float canvas11;
void vertex() {
	canvas11 = CANVAS_MATRIX[1][1];
}

void fragment() {
	float blur = blurC / canvas11;
	COLOR = vec4(0.);
	for(int i = 0; i < numlines; i++) {
		vec4 col1 = vec4(lineColorsrg[i].xy, lineColorsba[i].xy);
		
		vec2 a = lineStarts[i];
		vec2 b = lineEnds[i];
		if(a == b) {
			col1 *= vec4(0.);
			continue;
		}
		
		float lineWidth = (pow(lineThicknesses[i], 0.5) + lineThicknesses[i]) * 0.4;
		float lineLength = min(lineWidth, distance(a, b) * 0.75);
		
		vec2 c = b - a;
		c = vec2(c.y, -c.x);
		c = normalize(c) * lineThicknesses[i] / 2.;
		c += a;
		vec2 d = a - (c - a);
		vec2 e = b - (c - a);
		vec2 f = b + (c - a);
		
		col1 *= lineBlur(c, f, UV, blur);
		col1 *= lineBlur(e, d, UV, blur);
		col1 *= lineBlur(d, c, UV, blur);
		col1 *= lineBlur(f, e, UV, blur);
		
		vec4 linearColor = pow(COLOR, vec4(2.3));
		vec4 linearCol = pow(col1, vec4(2.3));
		vec4 mixedColor = mix(linearColor, linearCol, col1.a);
		COLOR = pow(mixedColor, vec4(1.0 / 2.3));
	}
}