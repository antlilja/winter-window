shader_type spatial;
uniform sampler2D viewportTexture;
uniform sampler2D noiseTexture;
uniform sampler2D memoryTexture;


void vertex() {
	// 229 237
	vec3 color = texture(noiseTexture, UV).rgb;

	float rawMean = (color.x + color.y + color.z) / 3.0;
	float clamped = clamp(rawMean, 0.0, 1.0);
	


	VERTEX.y = clamped;
	if (texture(viewportTexture, vec2(UV.x, UV.y * -1.0)).r >= 237.0/255.0){
		if (clamped != 0.0) {
		float deformFactor = 255.0 / (clamped * 255.0);
		float vertexPos = clamp(clamped - (clamped * deformFactor),0 ,1.0);
		VERTEX.y = vertexPos;
		}

	}







}

void fragment() {

	vec3 color = texture(noiseTexture, UV).rgb;
	float rawMean = (color.x + color.y + color.z) / 3.0;
	float clamped = clamp(rawMean, 0.5, 1.0);
	ALBEDO = vec3(clamped);

  // Visualize linear depth
  //ALBEDO.rgb = vec3(fract(linear_depth));
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
