shader_type canvas_item;
#include "LSquared.gdshaderinc"
#include "AClockwise.gdshaderinc"
#include "Constants.gdshaderinc"

const int numCircles = 32;
uniform vec2[numCircles] circleCenters;
uniform float[numCircles] circleRadii;
uniform float[numCircles] circleThicknesses;
uniform vec2[numCircles] circleColorsrg;
uniform vec2[numCircles] circleColorsba;

uniform int[numCircles] arcEndIndices;
const int numArcs = 128;
uniform vec2[numArcs] arcStarts;
uniform vec2[numArcs] arcEnds;

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
		float outerRadiusSquared = (circleRadii[i] + circleThicknesses[i] / 2.) * (circleRadii[i] + circleThicknesses[i] / 2.);
		float innerRadiusSquared = (circleRadii[i] - circleThicknesses[i] / 2.) * (circleRadii[i] - circleThicknesses[i] / 2.);
		float outerRadiusBlurSquared = (circleRadii[i] + circleThicknesses[i] / 2. + blur) * (circleRadii[i] + circleThicknesses[i] / 2. + blur);
		float innerRadiusBlurSquared = (circleRadii[i] - circleThicknesses[i] / 2. - blur) * (circleRadii[i] - circleThicknesses[i] / 2. - blur);
		vec2 center = circleCenters[i];
		float distanceSquared = l2(UV - center);
		
		if(distanceSquared <= outerRadiusSquared && distanceSquared >= innerRadiusSquared) {
			col *= 1.;
		}
		else if(distanceSquared > outerRadiusSquared && distanceSquared <= outerRadiusBlurSquared) {
			col *= sqrt(1. - (distanceSquared - outerRadiusSquared) / (outerRadiusBlurSquared - outerRadiusSquared)); 
		}
		else if(distanceSquared < innerRadiusSquared && distanceSquared >= innerRadiusBlurSquared) {
			col *= sqrt(1. - (innerRadiusSquared - distanceSquared) / (innerRadiusSquared - innerRadiusBlurSquared)); 
		}
		else {
			col *= 0.;
		}
		
		int j = 0;
		if(i > 0) {
			j = arcEndIndices[i-1];
		}

		for(; j < arcEndIndices[i]; j++) {
			vec2 arcStart = arcStarts[j];
			vec2 arcEnd = arcEnds[j];
			if(!aClockwise(UV - center, arcStart - center) && aClockwise(UV - center, arcEnd - center))
			{
				col *= 0.;
				break;
			}
		}
		
		COLOR.rgb = col.rgb + COLOR.rgb * (1. - col.a);
		COLOR.a = col.a + COLOR.a * (1. - col.a);
	}
	if (COLOR.a != 0.) COLOR.rgb /= COLOR.a;
}