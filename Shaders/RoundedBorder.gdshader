shader_type canvas_item;

#include "Constants.gdshaderinc"
#include "Noise.gdshaderinc"

uniform float innerDistance;
uniform float outerDistance;
uniform float outerRadius;
uniform float noDistortLength;
uniform vec4 bgCol;
uniform vec4 lineCol;
//uniform sampler2D noise;
uniform float noiseMean;
uniform vec2 noiseScale;
uniform float noiseSeed;

varying float aspectRatio;
varying float model11;
varying float canvas11;
varying float screen11;
void vertex() {
	model11 = MODEL_MATRIX[1][1];
	canvas11 = CANVAS_MATRIX[1][1];
	screen11 = SCREEN_MATRIX[1][1];
	aspectRatio = MODEL_MATRIX[0][0] / model11;
}

//float sampleNoise(float uv) {
	//return (texture(noise, vec2(mod(uv * noiseScale.x + noiseSeed, 1.), 0.)).r - noiseMean) * noiseScale.y;
//}

const float noiseScaleYConst = 0.1;
float sampleNoise(float uv) {
	return sNoise1D(uv * noiseScale.x + noiseSeed) * noiseScale.y * noiseScaleYConst;
}

void fragment() {
	vec2 newUV = vec2(UV.x * aspectRatio, UV.y);
	
	if(newUV.x >= newUV.y && aspectRatio - newUV.x >= newUV.y && 
		newUV.y <= 0.5) {
		float displacement = sampleNoise(UV.x);
		float displacementScale = min(newUV.x - newUV.y, aspectRatio - newUV.x - newUV.y);
		displacementScale = clamp(displacementScale, 0., noDistortLength) / noDistortLength;
		displacementScale = smoothstep(0., 1., displacementScale);
		newUV.y += displacement * displacementScale;
	}
	else if(newUV.x <= newUV.y && newUV.x <= 1. - newUV.y && 
		newUV.x <= 0.5 * aspectRatio) {
		float displacement = sampleNoise(UV.y + 1.);
		float displacementScale = min(newUV.y - newUV.x, 1. - newUV.y - newUV.x);
		displacementScale = clamp(displacementScale, 0., noDistortLength) / noDistortLength;
		displacementScale = smoothstep(0., 1., displacementScale);
		newUV.x += displacement * displacementScale;
	}
	else if(newUV.x >= 1. - newUV.y && aspectRatio - newUV.x >= 1. - newUV.y && 
		newUV.y >= 0.5) {
		float displacement = sampleNoise(UV.x + 2.);
		float displacementScale = min(newUV.x - (1. - newUV.y), aspectRatio - newUV.x - (1. - newUV.y));
		displacementScale = clamp(displacementScale, 0., noDistortLength) / noDistortLength;
		displacementScale = smoothstep(0., 1., displacementScale);
		newUV.y -= displacement * displacementScale;
	}
	else if(aspectRatio - newUV.x <= newUV.y && aspectRatio - newUV.x <= 1. - newUV.y && 
		newUV.x >= 0.5 * aspectRatio) {
		float displacement = sampleNoise(UV.y + 3.);
		float displacementScale = min(newUV.y - (aspectRatio - newUV.x), 1. - newUV.y - (aspectRatio - newUV.x));
		displacementScale = clamp(displacementScale, 0., noDistortLength) / noDistortLength;
		displacementScale = smoothstep(0., 1., displacementScale);
		newUV.x -= displacement * displacementScale;
	}
	
	vec2 topLeftCircleCenter = vec2(outerDistance + outerRadius);
	vec2 topRightCircleCenter = vec2(aspectRatio - topLeftCircleCenter.x, topLeftCircleCenter.y);
	vec2 bottomLeftCircleCenter = vec2(topLeftCircleCenter.x, 1. - topLeftCircleCenter.y);
	vec2 bottomRightCircleCenter = vec2(aspectRatio - topLeftCircleCenter.x, 1. - topLeftCircleCenter.y);
	vec2 circleCenter = vec2(-9999.);
	if(newUV.x <= topLeftCircleCenter.x && newUV.y <= topLeftCircleCenter.y) {
		circleCenter = topLeftCircleCenter;
	}
	else if(newUV.x >= topRightCircleCenter.x && newUV.y <= topRightCircleCenter.y) {
		circleCenter = topRightCircleCenter;
	}
	else if(newUV.x <= bottomLeftCircleCenter.x && newUV.y >= bottomLeftCircleCenter.y) {
		circleCenter = bottomLeftCircleCenter;
	}
	else if(newUV.x >= bottomRightCircleCenter.x && newUV.y >= bottomRightCircleCenter.y) {
		circleCenter = bottomRightCircleCenter;
	}
	
	float newBlur = blurC / canvas11;
	if(circleCenter != vec2(-9999.)) {
		float dist = length(newUV - circleCenter);
		float innerRadius = outerRadius + outerDistance - innerDistance;
		if(dist <= innerRadius - newBlur) {
			COLOR = bgCol;
		}
		else if(dist <= innerRadius) {
			float lerp = (innerRadius - dist) / newBlur;
			COLOR = bgCol * lerp + lineCol * (1. - lerp);
		}
		else if(dist <= outerRadius) {
			COLOR = lineCol;
		}
		else if(dist <= outerRadius + newBlur) {
			float lerp = (dist - outerRadius) / newBlur;
			COLOR = bgCol * lerp + lineCol * (1. - lerp);
		}
		else {
			COLOR = bgCol;
		}
	}
	else {
		float distFromEdge = newUV.x;
		distFromEdge = min(distFromEdge, newUV.y);
		distFromEdge = min(distFromEdge, aspectRatio - newUV.x);
		distFromEdge = min(distFromEdge, 1. - newUV.y);
		if(distFromEdge <= outerDistance - newBlur) {
			COLOR = bgCol;
		}
		else if(distFromEdge <= outerDistance) {
			float lerp = (outerDistance - distFromEdge) / newBlur;
			COLOR = bgCol * lerp + lineCol * (1. - lerp);
		}
		else if(distFromEdge <= innerDistance) {
			COLOR = lineCol;
		}
		else if(distFromEdge <= innerDistance + newBlur) {
			float lerp = (distFromEdge - innerDistance) / newBlur;
			COLOR = bgCol * lerp + lineCol * (1. - lerp);
		}
		else {
			COLOR = bgCol;
		}
	}
}