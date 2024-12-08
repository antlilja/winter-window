shader_type spatial;
uniform sampler2D viewportTexture;
uniform sampler2D noiseTexture;
uniform sampler2D memoryTexture;

void vertex() {
	vec3 color = texture(noiseTexture, UV).rgb;

	float rawMean = (color.x + color.y + color.z) / 3.0;
	float clamped = clamp(rawMean, 0.0, 1.0);

	VERTEX.y = clamped;
	vec3 mem = texture(memoryTexture, vec2(UV.x, UV.y * -1.0)).rgb;
	float mean = clamp(((mem.x + mem.y + mem.z) / 3.0), 0.0, 1.0);

	if (clamped != 0.0 && mean != 0.0) {
		float deformFactor = 255.0 / (mean * 255.0);
		float vertexPos = clamp(clamped - (clamped * deformFactor), 0.0, 1.0);
		VERTEX.y = vertexPos;
	}
	if (mean == 0.0){
		VERTEX.y = clamped;
	}
}

void fragment() {
	vec3 color = texture(noiseTexture, UV).rgb;
	float rawMean = (color.x + color.y + color.z) / 3.0;
	float clamped = clamp(rawMean, 0.5, 1.0);
	ALBEDO = vec3(clamped);
}