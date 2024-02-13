shader_type canvas_item;

uniform vec4 color;

void fragment() {
	if ((UV.x - 0.125) * (UV.x - 0.125) + (UV.y - 0.125) * (UV.y - 0.125) <= 0.125 * 0.125)
	{
		COLOR = color;
	}
	else
	{
		COLOR = vec4(0.);
	}
}