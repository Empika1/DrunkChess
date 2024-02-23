shader_type canvas_item;

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

float l2(vec2 vec) {
	return vec.x * vec.x + vec.y * vec.y;
}

bool aClockwise(vec2 a, vec2 b) {
	return a.x * b.y > a.y * b.x;
}

void fragment() {
	float blur = 0.0006;
	
	COLOR = vec4(0.);
	
	for(int i = 0; i < numCircles; i++) {
		vec4 col = vec4(circleColorsrg[i].xy, circleColorsba[i].xy);
		if(col.a == 0.)
			break;
		float outerRadiusSquared = circleRadii[i] * circleRadii[i];
		float innerRadiusSquared = (circleRadii[i] - circleThicknesses[i]) * (circleRadii[i] - circleThicknesses[i]);
		float outerRadiusBlurSquared = (circleRadii[i] + blur) * (circleRadii[i] + blur);
		float innerRadiusBlurSquared = (circleRadii[i] - circleThicknesses[i] - blur) * (circleRadii[i] - circleThicknesses[i] - blur);
		vec2 center = circleCenters[i];
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
		
		int j = 0;
		if(i > 0) {
			j = arcEndIndices[i-1];
		}

		for(; j < arcEndIndices[i]; j++) {
			vec2 arcStart = arcStarts[j];
			vec2 arcEnd = arcEnds[j];
			if(!aClockwise(UV - center, arcStart - center) && aClockwise(UV - center, arcEnd - center))
			{
				col.a *= 0.;
				break;
			}
		}
		
		vec4 linearColor = pow(COLOR, vec4(2.3));
		vec4 linearCol = pow(col, vec4(2.3));
		vec4 mixedColor = mix(linearColor, linearCol, col.a);
		COLOR = pow(mixedColor, vec4(1.0 / 2.3));
	}
}