shader_type canvas_item;
#include "LSquared.gdshaderinc"
#include "Constants.gdshaderinc"

const int numCircles = 64;
uniform vec2[numCircles] circleCenters;
uniform float[numCircles] circleRadii;
uniform vec2[numCircles] circleColorsrg;
uniform vec2[numCircles] circleColorsba;

uniform float realWidth;
uniform float realHeight;

varying float screen11;
void vertex() {
	screen11 = SCREEN_MATRIX[1][1];
}

void fragment() {
	float blur = getBlurValue(screen11, realHeight);
	
	COLOR = vec4(0.);
	for(int i = 0; i < numCircles; i++) {
		vec4 col = vec4(circleColorsrg[i].xy, circleColorsba[i].xy);
		if(col.a == 0.)
			break;
		float radiusSquared = circleRadii[i] * circleRadii[i];
		float radiusBlurSquared = (circleRadii[i] + blur) * (circleRadii[i] + blur);
		float distanceSquared = l2(UV - circleCenters[i]);
		
		if(distanceSquared <= radiusSquared) {
			col *= 1.;
		}
		else if(distanceSquared <= radiusBlurSquared) {
			col *= sqrt(1. - (distanceSquared - radiusSquared) / (radiusBlurSquared - radiusSquared)); 
		}
		else {
			col *= 0.;
		}
		
		COLOR.rgb = col.rgb + COLOR.rgb * (1. - col.a);
		COLOR.a = col.a + COLOR.a * (1. - col.a);
	}
	if (COLOR.a != 0.) COLOR.rgb /= COLOR.a;
}