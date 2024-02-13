shader_type canvas_item;

uniform vec4 color;
uniform vec2 center;
uniform float radius;

void fragment() {
	if ((UV.x - center.x) * (UV.x - center.x) + (UV.y - center.y) * (UV.y - center.y) <= radius * radius)
	{
		COLOR = color;
	}
	else
	{
		COLOR = vec4(0.);
	}
}