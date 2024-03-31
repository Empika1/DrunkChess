shader_type canvas_item;

uniform float slice;

#include "Noise.gdshaderinc"

void fragment() {
	COLOR = vec4(vec3(0.5 * sNoise1D(UV.x * 5.) + 0.5), 1.);
}