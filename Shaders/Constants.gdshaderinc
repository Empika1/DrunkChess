const float blurC = 15.;
float getBlurValue(float screen11, float realHeight) {
	return blurC * pow(screen11, 0.5) / realHeight;
}