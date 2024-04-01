shader_type canvas_item;
#include "Noise.gdshaderinc"

uniform float posterizationLayers;
uniform float timeScale;
uniform float realWidth;
uniform float realHeight;
uniform float scale;
uniform vec4 layer1Col1: source_color;
uniform vec4 layer1Col2: source_color;

void fragment() {
	float aspectRatio = realWidth / realHeight;
	vec2 newUV = vec2((UV.x - 0.5) * aspectRatio, UV.y - 0.5) * scale;
	float noiseVal = sNoise3D(vec3(newUV, TIME * timeScale)) * 0.5 + 0.5;
	noiseVal = floor(noiseVal * posterizationLayers) / posterizationLayers;
	COLOR = layer1Col1 * noiseVal + layer1Col2 * (1. - noiseVal);
}