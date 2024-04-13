shader_type canvas_item;
#include "Noise.gdshaderinc"
#include "Constants.gdshaderinc"

uniform float posterizationLayers;
uniform float timeScale;
uniform float realWidth;
uniform float realHeight;
uniform float scale;
uniform vec4 layer1Col1: source_color;
uniform vec4 layer1Col2: source_color;

varying float screen11;
void vertex() {
	screen11 = SCREEN_MATRIX[1][1];
}

void fragment() {
	float blur = getBlurValue(screen11, realHeight) * 5.;
	
	float aspectRatio = realWidth / realHeight;
	vec2 newUV = vec2((UV.x - 0.5) * aspectRatio, UV.y - 0.5) * scale;
	float noiseVal = sNoise3D(vec3(newUV, TIME * timeScale)) * 0.5 + 0.5;
	noiseVal = noiseVal * posterizationLayers;
	float modNoiseVal = mod(noiseVal, 1.);
	float floorNoiseVal = floor(noiseVal);
	if(modNoiseVal <= blur) {
		float lerp = modNoiseVal / blur;
		noiseVal = floorNoiseVal / posterizationLayers * lerp +
				   (floorNoiseVal - 1.) / posterizationLayers * (1. - lerp);
	}
	else {
		noiseVal = floorNoiseVal / posterizationLayers;
	}
	COLOR = layer1Col1 * noiseVal + layer1Col2 * (1. - noiseVal);
}