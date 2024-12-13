shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D colour_texture;
uniform sampler2D depth_texture;

uniform bool show_depth = false;
uniform float far = 8.0;
uniform float near = 0.1;

void vertex() {
  POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).r / 1000.0f;
	depth = clamp(depth, near, far);
	depth = 1.0 - ((depth * (far / (far - near))) + ((far * near) / (near - far))) / depth;
	DEPTH = depth;

	if(show_depth) {
		ALBEDO = vec3(depth);
	} else {
		ALBEDO = texture(colour_texture, SCREEN_UV).rgb;
	}
}
