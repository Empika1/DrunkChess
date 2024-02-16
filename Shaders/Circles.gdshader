shader_type canvas_item;

const int numCircles = 64;
uniform vec2[numCircles] circleCenters;
uniform float[numCircles] circleRadii;
uniform vec2[numCircles] circleColorsrg;
uniform vec2[numCircles] circleColorsba;

float l2(vec2 vec) {
	return vec.x * vec.x + vec.y * vec.y;
}

void fragment() {
	float blur = 0.0002;
	
	COLOR = vec4(0.);
	for(int i = 0; i < numCircles; i++) {
		vec4 lineCol = vec4(circleColorsrg[i].xy, circleColorsba[i].xy);
		if(lineCol.a == 0.)
			break;
		vec4 col = lineCol;
		float radiusSquared = circleRadii[i] * circleRadii[i];
		float radiusBlurSquared = (circleRadii[i] + blur) * (circleRadii[i] + blur);
		float distanceSquared = l2(UV - circleCenters[i]);
		
		if(distanceSquared <= radiusSquared) {
			col.a *= 1.;
		}
		else if(distanceSquared <= radiusBlurSquared) {
			col.a *= 1. - (distanceSquared - radiusSquared) / (radiusBlurSquared - radiusSquared); 
		}
		else {
			col.a *= 0.;
		}
		COLOR = mix(COLOR, col, col.a);
	}
}