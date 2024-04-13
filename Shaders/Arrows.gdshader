shader_type canvas_item;
#include "LineBlur.gdshaderinc"
#include "Distort.gdshaderinc"
#include "Constants.gdshaderinc"

const int numArrows = 128;
uniform vec2[numArrows] arrowStarts;
uniform vec2[numArrows] arrowEnds;
uniform vec2[numArrows] arrowColorsrg;
uniform vec2[numArrows] arrowColorsba;
uniform float[numArrows] arrowThicknesses;
uniform vec2[numArrows] arrowDistortPoints;

uniform float realWidth;
uniform float realHeight;

varying float screen11;
void vertex() {
	screen11 = SCREEN_MATRIX[1][1];
}

void fragment() {
	float blur = getBlurValue(screen11, realHeight);
	COLOR = vec4(0.);
	for(int i = 0; i < numArrows; i++) {
		vec4 col1 = vec4(arrowColorsrg[i].xy, arrowColorsba[i].xy);
		vec4 col2 = vec4(arrowColorsrg[i].xy, arrowColorsba[i].xy);
		
		vec2 a = arrowStarts[i];
		vec2 b = arrowEnds[i];
		if(a == b) {
			col1 *= vec4(0.);
			col2 *= vec4(0.);
			continue;
		}
		vec2 distortUV = distort(a, b, arrowDistortPoints[i], UV);
		
		float arrowWidth = (pow(arrowThicknesses[i], 0.5) + arrowThicknesses[i]) * 0.4;
		float arrowLength = min(arrowWidth, distance(a, b) * 0.75);
		
		vec2 c = b - a;
		c = normalize(c) * arrowLength;
		c = b - c;
		
		vec2 d = c - a;
		d = vec2(d.y, -d.x);
		d = normalize(d) * arrowThicknesses[i] / 2.;
		d += a;
		vec2 e = a - (d - a);
		vec2 f = c - (d - a);
		vec2 g = c + (d - a);
		
		col1 *= lineBlur(d, g, distortUV, blur);
		col1 *= lineBlur(f, e, distortUV, blur);
		col1 *= lineBlur(e, d, distortUV, blur);
		col1 *= lineBlur(g, f, distortUV, blur);
		
		vec2 h = c - a;
		h = vec2(h.y, -h.x);
		h = normalize(h) * arrowWidth / 2.;
		h += c;
		vec2 i = c - (h - c);
		
		col2 *= lineBlur(i, h, distortUV, blur);
		col2 *= lineBlur(b, i, distortUV, blur);
		col2 *= lineBlur(h, b, distortUV, blur);
		
		vec4 maxCol = max(col1, col2);
		
		vec4 linearColor = pow(COLOR, vec4(2.3));
		vec4 linearCol = pow(maxCol, vec4(2.3));
		vec4 mixedColor = mix(linearColor, linearCol, maxCol.a);
		COLOR = pow(mixedColor, vec4(1.0 / 2.3));
	}
}