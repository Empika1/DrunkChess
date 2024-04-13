shader_type canvas_item;
#include "LineBlur.gdshaderinc"
#include "Constants.gdshaderinc"

const int numlines = 16;
uniform vec2[numlines] lineStarts;
uniform vec2[numlines] lineEnds;
uniform vec2[numlines] lineColorsrg;
uniform vec2[numlines] lineColorsba;
uniform float[numlines] lineThicknesses;

uniform float realWidth;
uniform float realHeight;

varying float screen11;
void vertex() {
	screen11 = SCREEN_MATRIX[1][1];
}

void fragment() {
	float blur = getBlurValue(screen11, realHeight);
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
		
		COLOR.rgb = col1.rgb + COLOR.rgb * (1. - col1.a);
		COLOR.a = col1.a + COLOR.a * (1. - col1.a);
	}
	if (COLOR.a != 0.) COLOR.rgb /= COLOR.a;
}