vec2 proj(vec2 a_, vec2 b_) {
	return dot(a_, b_) / dot(b_, b_) * b_;
}

vec2 distort(vec2 aVec, vec2 bVec, vec2 cVec, vec2 dVec) {
	vec2 c_ = proj(cVec - aVec, bVec - aVec) + aVec;
	vec2 d_ = proj(dVec - aVec, bVec - aVec) + aVec;
	float scale;
	float dotA = dot(d_-c_, aVec-c_);
	float maxDotA = dot(aVec-c_, aVec-c_);
	float dotB = dot(d_-c_, bVec-c_);
	float maxDotB = dot(bVec-c_, bVec-c_);
	if(dotA >= 0.) {
		scale = dotA / maxDotA;
	}
	else {
		scale = dotB / maxDotB;
	}
	scale = pow(scale, 2);
	scale = 1. - scale;
	return dVec + (c_ - cVec) * scale;
}