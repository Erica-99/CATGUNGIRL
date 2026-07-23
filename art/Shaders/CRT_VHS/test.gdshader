shader_type spatial;
float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

vec3 CRT(vec3 color, vec2 uvs, float time) {
	color = vec3(.1);
	float t1 = remap(sin(uvs.y * 200. - time * 10.), -1., 1., .9, 1.);
	float t2 = remap(sin(uvs.y * 40. + time * 2. ), -1., 1., .9, 1.);
	return color * t1 * t2;
}
void vertex() {
	// Called for every vertex the material is visible on.
	
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO.rgb = CRT(ALBEDO.rgb, UV, TIME);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
