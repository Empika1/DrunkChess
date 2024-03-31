shader_type canvas_item;
#include "LSquared.gdshaderinc"
#include "Constants.gdshaderinc"

const int numCircles = 64;
uniform vec2[numCircles] circleCenters;
uniform float[numCircles] circleRadii;
uniform vec2[numCircles] circleColorsrg;
uniform vec2[numCircles] circleColorsba;

varying float canvas11;
void vertex() {
	canvas11 = CANVAS_MATRIX[1][1];
}

void fragment() {
	float blur = blurC / canvas11;
	
	COLOR = vec4(0.);
	for(int i = 0; i < numCircles; i++) {
		vec4 col = vec4(circleColorsrg[i].xy, circleColorsba[i].xy);
		if(col.a == 0.)
			break;
		float radiusSquared = circleRadii[i] * circleRadii[i];
		float radiusBlurSquared = (circleRadii[i] + blur) * (circleRadii[i] + blur);
		float distanceSquared = l2(UV - circleCenters[i]);
		
		if(distanceSquared <= radiusSquared) {
			col.a *= 1.;
		}
		else if(distanceSquared <= radiusBlurSquared) {
			col.a *= sqrt(1. - (distanceSquared - radiusSquared) / (radiusBlurSquared - radiusSquared)); 
		}
		else {
			col.a *= 0.;
		}
		vec4 linearColor = pow(COLOR, vec4(2.3));
		vec4 linearCol = pow(col, vec4(2.3));
		vec4 mixedColor = mix(linearColor, linearCol, col.a);
		COLOR = pow(mixedColor, vec4(1.0 / 2.3));
	}
}