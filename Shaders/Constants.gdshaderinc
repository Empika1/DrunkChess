const float blurC = 75.;
float getBlurValue(float screen11, float realHeight) {
	return blurC * screen11 / realHeight;
}