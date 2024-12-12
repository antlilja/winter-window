shader_type spatial;
render_mode unshaded, fog_disabled;
uniform sampler2D depth_texture : source_color, hint_depth_texture;

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;

	ALBEDO = vec3(clamp(world_position.y - 0.25, 0.0, 1.0));
}
