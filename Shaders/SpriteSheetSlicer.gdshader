shader_type canvas_item;

uniform int width;
uniform int height;
uniform int frame;

void fragment() {
	int x = frame % width;
	int y = frame / width;
	COLOR = texture(TEXTURE, vec2((UV.x + float(x)) / float(width), (UV.y + float(y)) / float(height)));
}