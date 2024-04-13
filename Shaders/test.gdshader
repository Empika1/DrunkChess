shader_type canvas_item;

uniform float realWidth;
uniform float realHeight;

varying mat4 screenmat;
varying mat4 canvasmat;
varying mat4 modelmat;
void vertex() {
	screenmat = SCREEN_MATRIX;
	canvasmat = CANVAS_MATRIX;
	modelmat = MODEL_MATRIX;
}

void fragment() {
	COLOR = vec4(vec3(0.1 * max(screenmat[0][0] * realWidth, screenmat[1][1] * realHeight)), 1.);
}
