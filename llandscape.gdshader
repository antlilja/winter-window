shader_type spatial;
uniform sampler2D memoryTexture;

void vertex() {
	float normalizedHeight = clamp(texture(memoryTexture, vec2(UV.x, UV.y * -1.0)).r, 0.0, 1.0);
	VERTEX.y = clamp(normalizedHeight, 0.0, 1.0);
}

void fragment() {
	float normalizedHeight = clamp(texture(memoryTexture, vec2(UV.x, UV.y * -1.0)).r, 0.5, 1.0);
	ALBEDO = vec3(normalizedHeight);
}