shader_type canvas_item;

uniform float thresh;
uniform vec4 color;

void fragment() {
	COLOR = color;
	COLOR.a = 0.;
	if(abs(abs(UV.x - 0.5) - abs(UV.y - 0.5 )) < thresh)
	{
		COLOR.a = color.a;
	}
}