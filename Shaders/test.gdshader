shader_type canvas_item;

void fragment() {
	COLOR = vec4(vec3(TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x), 1.);
}