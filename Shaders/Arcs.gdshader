shader_type canvas_item;
#include "LSquared.gdshaderinc"
#include "AClockwise.gdshaderinc"
#include "Constants.gdshaderinc"

const int numArcs = 64;
uniform vec2[numArcs] arcCenters;
uniform float[numArcs] arcRadii;
uniform float[numArcs] arcThicknesses;
uniform vec2[numArcs] arcColorsrg;
uniform vec2[numArcs] arcColorsba;
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
	for(int i = 0; i < numArcs; i++) {
		vec4 col = vec4(arcColorsrg[i].xy, arcColorsba[i].xy);
		if(col.a == 0.)
			break;
		float outerRadiusSquared = arcRadii[i] * arcRadii[i];
		float innerRadiusSquared = (arcRadii[i] - arcThicknesses[i] / 2.) * (arcRadii[i] - arcThicknesses[i] / 2.);
		float outerRadiusBlurSquared = (arcRadii[i] + blur) * (arcRadii[i] + blur);
		float innerRadiusBlurSquared = (arcRadii[i] - arcThicknesses[i] / 2. - blur) * (arcRadii[i] - arcThicknesses[i] / 2. - blur);
		vec2 center = arcCenters[i];
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
		
		vec2 arcStart = arcStarts[i];
		vec2 arcEnd = arcEnds[i];
		if(aClockwise(UV - center, arcStart - center) || !aClockwise(UV - center, arcEnd - center))
		{
			col *= 0.;
		}
		
		COLOR.rgb = col.rgb + COLOR.rgb * (1. - col.a);
		COLOR.a = col.a + COLOR.a * (1. - col.a);
	}
	if (COLOR.a != 0.) COLOR.rgb /= COLOR.a;
}