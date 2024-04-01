shader_type canvas_item;

#include "Constants.gdshaderinc"
#include "Noise.gdshaderinc"

uniform vec4 outerDistances; //x, y, z, w -> top, left, bottom, right
uniform float thickness;
uniform float outerRadius;
uniform float noDistortLength;
uniform vec4 insideBgCol: source_color;
uniform vec4 outsideBgCol: source_color;
uniform vec4 lineCol: source_color;
//uniform sampler2D noise;
uniform vec2 noiseScale;
uniform float noiseSeed;
uniform float realWidth;
uniform float realHeight;

//varying float aspectRatio;
//varying float model11;
varying float canvas11;
//varying float screen11;
void vertex() {
	//model11 = MODEL_MATRIX[1][1];
	canvas11 = CANVAS_MATRIX[1][1];
	//screen11 = SCREEN_MATRIX[1][1];
	//aspectRatio = (CANVAS_MATRIX[0][0] / CANVAS_MATRIX[1][1]) * (MODEL_MATRIX[0][0] / MODEL_MATRIX[1][1]);
}

//float sampleNoise(float uv) {
	//return (texture(noise, vec2(mod(uv * noiseScale.x + noiseSeed, 1.), 0.)).r - noiseMean) * noiseScale.y;
//}

const float noiseScaleYConst = 0.1;
float sampleNoise(float uv) {
	return sNoise1D(uv * noiseScale.x + noiseSeed) * noiseScale.y * noiseScaleYConst;
}

vec4 returnLineCol(float start, float end, float value, float blur) {
	if(value <= start - blur) {
		return outsideBgCol;
	}
	else if(value <= start) {
		float lerp = (start - value) / blur;
		return outsideBgCol * lerp + lineCol * (1. - lerp);
	}
	else if(value <= end) {
		return lineCol;
	}
	else if(value <= end + blur) {
		float lerp = (value - end) / blur;
		return insideBgCol * lerp + lineCol * (1. - lerp);
	}
	else {
		return insideBgCol;
	}
}

void fragment() {
	float aspectRatio = realWidth / realHeight;
	vec2 newUV = vec2(UV.x * aspectRatio, UV.y);
	
	if(newUV.x >= newUV.y && aspectRatio - newUV.x >= newUV.y && 
		newUV.y <= 0.5) {
		float displacement = sampleNoise(newUV.x);
		float displacementScale = min(newUV.x - newUV.y, aspectRatio - newUV.x - newUV.y);
		displacementScale = clamp(displacementScale, 0., noDistortLength) / noDistortLength;
		displacementScale = smoothstep(0., 1., displacementScale);
		newUV.y += displacement * displacementScale;
	}
	else if(newUV.x <= newUV.y && newUV.x <= 1. - newUV.y && 
		newUV.x <= 0.5 * aspectRatio) {
		float displacement = sampleNoise(newUV.y + 1.);
		float displacementScale = min(newUV.y - newUV.x, 1. - newUV.y - newUV.x);
		displacementScale = clamp(displacementScale, 0., noDistortLength) / noDistortLength;
		displacementScale = smoothstep(0., 1., displacementScale);
		newUV.x += displacement * displacementScale;
	}
	else if(newUV.x >= 1. - newUV.y && aspectRatio - newUV.x >= 1. - newUV.y && 
		newUV.y >= 0.5) {
		float displacement = sampleNoise(newUV.x + 2.);
		float displacementScale = min(newUV.x - (1. - newUV.y), aspectRatio - newUV.x - (1. - newUV.y));
		displacementScale = clamp(displacementScale, 0., noDistortLength) / noDistortLength;
		displacementScale = smoothstep(0., 1., displacementScale);
		newUV.y -= displacement * displacementScale;
	}
	else if(aspectRatio - newUV.x <= newUV.y && aspectRatio - newUV.x <= 1. - newUV.y && 
		newUV.x >= 0.5 * aspectRatio) {
		float displacement = sampleNoise(newUV.y + 3.);
		float displacementScale = min(newUV.y - (aspectRatio - newUV.x), 1. - newUV.y - (aspectRatio - newUV.x));
		displacementScale = clamp(displacementScale, 0., noDistortLength) / noDistortLength;
		displacementScale = smoothstep(0., 1., displacementScale);
		newUV.x -= displacement * displacementScale;
	}
	
	vec2 topLeftCircleCenter = vec2(outerDistances.y + outerRadius, outerDistances.x + outerRadius);
	vec2 topRightCircleCenter = vec2(aspectRatio - outerDistances.w - outerRadius, outerDistances.x + outerRadius);
	vec2 bottomLeftCircleCenter = vec2(outerDistances.y + outerRadius, 1. - outerDistances.z - outerRadius);
	vec2 bottomRightCircleCenter = vec2(aspectRatio - outerDistances.w - outerRadius, 1. - outerDistances.z - outerRadius);
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
		float innerRadius = outerRadius - thickness;
		if(dist <= innerRadius - newBlur) {
			COLOR = insideBgCol;
		}
		else if(dist <= innerRadius) {
			float lerp = (innerRadius - dist) / newBlur;
			COLOR = insideBgCol * lerp + lineCol * (1. - lerp);
		}
		else if(dist <= outerRadius) {
			COLOR = lineCol;
		}
		else if(dist <= outerRadius + newBlur) {
			float lerp = (dist - outerRadius) / newBlur;
			COLOR = outsideBgCol * lerp + lineCol * (1. - lerp);
		}
		else {
			COLOR = outsideBgCol;
		}
	}
	else {
		if(newUV.x <= topLeftCircleCenter.x) {
			COLOR = returnLineCol(outerDistances.y, outerDistances.y + thickness, newUV.x, newBlur);
		}
		else if(newUV.x >= topRightCircleCenter.x) {
			COLOR = returnLineCol(outerDistances.w, outerDistances.w + thickness, aspectRatio - newUV.x, newBlur);
		}
		else if(newUV.y <= topLeftCircleCenter.y) {
			COLOR = returnLineCol(outerDistances.x, outerDistances.x + thickness, newUV.y, newBlur);
		}
		else {
			COLOR = returnLineCol(outerDistances.z, outerDistances.z + thickness, 1. - newUV.y, newBlur);
		}
	}
}