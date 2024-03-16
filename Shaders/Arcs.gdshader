shader_type canvas_item;
#include "LSquared.gdshaderinc"
#include "AClockwise.gdshaderinc"

const int numArcs = 64;
uniform vec2[numArcs] arcCenters;
uniform float[numArcs] arcRadii;
uniform float[numArcs] arcThicknesses;
uniform vec2[numArcs] arcColorsrg;
uniform vec2[numArcs] arcColorsba;
uniform vec2[numArcs] arcStarts;
uniform vec2[numArcs] arcEnds;

void fragment() {
	float blur = 0.0006;
	
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
			col.a *= 1.;
		}
		else if(distanceSquared > outerRadiusSquared && distanceSquared <= outerRadiusBlurSquared) {
			col.a *= sqrt(1. - (distanceSquared - outerRadiusSquared) / (outerRadiusBlurSquared - outerRadiusSquared)); 
		}
		else if(distanceSquared < innerRadiusSquared && distanceSquared >= innerRadiusBlurSquared) {
			col.a *= sqrt(1. - (innerRadiusSquared - distanceSquared) / (innerRadiusSquared - innerRadiusBlurSquared)); 
		}
		else {
			col.a *= 0.;
		}
		
		vec2 arcStart = arcStarts[i];
		vec2 arcEnd = arcEnds[i];
		if(aClockwise(UV - center, arcStart - center) || !aClockwise(UV - center, arcEnd - center))
		{
			col.a *= 0.;
		}
		
		vec4 linearColor = pow(COLOR, vec4(2.3));
		vec4 linearCol = pow(col, vec4(2.3));
		vec4 mixedColor = mix(linearColor, linearCol, col.a);
		COLOR = pow(mixedColor, vec4(1.0 / 2.3));
	}
}