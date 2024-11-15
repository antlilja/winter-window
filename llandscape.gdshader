shader_type spatial;
uniform sampler2D normalTexture;
uniform sampler2D noiseTexture;

void vertex() {
	vec3 color = texture(noiseTexture, UV).rgb;
	float rawMean = (color.x + color.y + color.z) / 3.0;
	float clamped = clamp(rawMean, 0.0, 1.0);
	VERTEX.y = clamped;
	
}

void fragment() {
	vec3 color = texture(noiseTexture, UV).rgb;
	float rawMean = (color.x + color.y + color.z) / 3.0;
	float clamped = clamp(rawMean, 0.5, 1.0);	
	ALBEDO = vec3(clamped);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
