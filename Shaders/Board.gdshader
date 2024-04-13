shader_type canvas_item;
#include "Constants.gdshaderinc"

uniform vec4 col1: source_color;
uniform vec4 col2: source_color;
uniform float numSquares;
uniform float numWaves;
uniform vec2 squareOffset;
uniform vec2 distort;
uniform float cornerRadius;

uniform float realWidth;
uniform float realHeight;

float checkerValue(vec2 _UV, float blur) {
	blur *= numSquares;
	float halfBlur = blur * 0.5;
	int segment = 0;
	if(_UV.x >= blur * 0.1) segment += 1;
	if(_UV.x >= 1. - blur * 0.1) segment += 1;
	if(_UV.y >= blur * 0.1) segment += 3;
	if(_UV.y >= 1. - blur * 0.1) segment += 3;
	
	float x;
	float modUVx = mod(_UV.x * numSquares, 2.);
	if(modUVx <= halfBlur)
		x = (1. - modUVx / halfBlur) * 0.5;
	else if(modUVx >= 2. - halfBlur)
		x = (1. - (modUVx - (2. - halfBlur)) / halfBlur) * 0.5 + 0.5;
	else if(modUVx <= 1. - halfBlur)
		x = 0.;
	else if(modUVx <= 1. + halfBlur)
		x = (modUVx - (1. - halfBlur)) / blur;
	else
		x = 1.;
	
	float y;
	float modUVy = mod(_UV.y * numSquares, 2.);
	if(modUVy <= halfBlur)
		y = (1. - modUVy / halfBlur) * 0.5;
	else if(modUVy >= 2. - halfBlur)
		y = (1. - (modUVy - (2. - halfBlur)) / halfBlur) * 0.5 + 0.5;
	else if(modUVy <= 1. - halfBlur)
		y = 0.;
	else if(modUVy <= 1. + halfBlur)
		y = (modUVy - (1. - halfBlur)) / blur;
	else
		y = 1.;
	
	switch(segment) {
		case 0:
			return 0.;
		case 1:
			return x;
		case 2:
			return 1.;
		case 3:
			return y;
		case 4:
			return x + y - 2. * x * y;
		case 5:
			return 1. - y;
		case 6:
			return 1.;
		case 7:
			return 1. - x;
		case 8:
			return 0.;
	}
}

varying float screen11;
void vertex() {
	screen11 = SCREEN_MATRIX[1][1];
}

void fragment() {
	float blur = getBlurValue(screen11, realHeight);
	
	vec2 topLeftCorner = vec2(cornerRadius, cornerRadius);
	vec2 topRightCorner = vec2(1. - cornerRadius, cornerRadius);
	vec2 bottomLeftCorner = vec2(cornerRadius, 1. - cornerRadius);
	vec2 bottomRightCorner = vec2(1. - cornerRadius, 1. - cornerRadius);
	if(UV.x <= topLeftCorner.x && UV.y <= topLeftCorner.y && 
		length(UV - topLeftCorner) >= cornerRadius) {
		COLOR = vec4(0.);
	}
	else if(UV.x >= topRightCorner.x && UV.y <= topRightCorner.y && 
		length(UV - topRightCorner) >= cornerRadius) {
		COLOR = vec4(0.);
	}
	else if(UV.x <= bottomLeftCorner.x && UV.y >= bottomLeftCorner.y && 
		length(UV - bottomLeftCorner) >= cornerRadius) {
		COLOR = vec4(0.);
	}
	else if(UV.x >= bottomRightCorner.x && UV.y >= bottomRightCorner.y && 
		length(UV - bottomRightCorner) >= cornerRadius) {
		COLOR = vec4(0.);
	}
	else {
		vec2 newUV = UV;
		newUV.y += cos((UV.x + squareOffset.x) * PI * 2. * numWaves) * distort.x;
		newUV.x += cos((UV.y + squareOffset.y) * PI * 2. * numWaves) * distort.y;
		
		float lerp = checkerValue(newUV, blur);
		COLOR = lerp * col1 + (1. - lerp) * col2;
	}
}