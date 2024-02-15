shader_type canvas_item;

uniform vec4 color;
uniform vec2 center;
uniform float radius;

void fragment() {
	float distSquared = (UV.x - center.x) * (UV.x - center.x) + (UV.y - center.y) * (UV.y - center.y);
	float dist = sqrt(distSquared);
	float blur = 0.015 * TEXTURE_PIXEL_SIZE.x;
	COLOR.rgb = color.rgb;
	COLOR.a = 1.;
	if(dist <= radius)
	{
		COLOR.a = color.a;
	}
	else if(dist <= radius + blur)
	{
		COLOR.a = (1. - (dist - radius) / blur) * color.a;
	}
	else
	{
		COLOR.a = 0.;
	}
}