shader_type canvas_item;

uniform float innerDistance;
uniform float outerDistance;
uniform float outerRadius;
uniform float aspectRatio; //width / height
uniform vec4 bgCol;
uniform vec4 lineCol;

const float blur = 0.0006;

void fragment() {
	float widthScale;
	float heightScale;
	if(aspectRatio < 1.) {
		heightScale = 1.;
		widthScale = aspectRatio;
	}
	else {
		widthScale = 1.;
		heightScale = 1. / aspectRatio;
	}
	
	vec2 transformedUV = UV;
	transformedUV.x *= widthScale;
	transformedUV.y *= heightScale;
	if(UV.x > widthScale * 0.5 / widthScale) {
		transformedUV.x += 1. - widthScale;
	}
	if(UV.y > heightScale * 0.5 / heightScale) {
		transformedUV.y += 1. - heightScale;
	}
	
	vec2 topLeftCircleCenter = vec2(outerDistance + outerRadius);
	vec2 topRightCircleCenter = vec2(1. - topLeftCircleCenter.x, topLeftCircleCenter.y);
	vec2 bottomLeftCircleCenter = vec2(topLeftCircleCenter.x, 1. - topLeftCircleCenter.y);
	vec2 bottomRightCircleCenter = vec2(1. - topLeftCircleCenter.x, 1. - topLeftCircleCenter.y);
	
	vec2 circleCenter = vec2(-1.);
	if(transformedUV.x <= topLeftCircleCenter.x && transformedUV.y <= topLeftCircleCenter.y) {
		circleCenter = topLeftCircleCenter;
	}
	else if(transformedUV.x >= topRightCircleCenter.x && transformedUV.y <= topRightCircleCenter.y) {
		circleCenter = topRightCircleCenter;
	}
	else if(transformedUV.x <= bottomLeftCircleCenter.x && transformedUV.y >= bottomLeftCircleCenter.y) {
		circleCenter = bottomLeftCircleCenter;
	}
	else if(transformedUV.x >= bottomRightCircleCenter.x && transformedUV.y >= bottomRightCircleCenter.y) {
		circleCenter = bottomRightCircleCenter;
	}
	
	if(circleCenter != vec2(-1.)) {
		float dist = length(transformedUV - circleCenter);
		float innerRadius = outerRadius + outerDistance - innerDistance;
		if(dist < innerRadius - blur) {
			COLOR = bgCol;
		}
		else if(dist < innerRadius) {
			float lerp = (innerRadius - dist) / blur;
			COLOR = bgCol * lerp + lineCol * (1. - lerp);
		}
		else if(dist < outerRadius) {
			COLOR = lineCol;
		}
		else if(dist < outerRadius + blur) {
			float lerp = (outerRadius + blur - dist) / blur;
			COLOR = lineCol * lerp + bgCol * (1. - lerp);
		}
		else {
			COLOR = bgCol;
		}
	}
	else {
		float maxDist = max(abs(transformedUV.x - 0.5), abs(transformedUV.y - 0.5));
		if(maxDist < 0.5 - innerDistance - blur) {
			COLOR = bgCol;
		}
		else if(maxDist < 0.5 - innerDistance) {
			float lerp = (0.5 - innerDistance - maxDist) / blur;
			COLOR = bgCol * lerp + lineCol * (1. - lerp);
		}
		else if(maxDist < 0.5 - outerDistance) {
			COLOR = lineCol;
		}
		else if(maxDist < 0.5 - outerDistance + blur) {
			float lerp = (0.5 - outerDistance + blur - maxDist) / blur;
			COLOR = lineCol * lerp + bgCol * (1. - lerp);
		}
		else {
			COLOR = bgCol;
		}
	}
}