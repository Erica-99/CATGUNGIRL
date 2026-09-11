shader_type spatial;
render_mode unshaded, fog_disabled, depth_draw_never, cull_disabled;


uniform sampler2D depth_texture : hint_depth_texture;

uniform vec4 fog_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float plane_depth = 30.0;
uniform float fog_near_offset = -10.0;
uniform float fog_far_offset = 30.0;
uniform float depth_curve : hint_range(0.05, 8.0) = 1.0;
uniform float forefront : hint_range(0.0, 1.0) = 0.0;
uniform float max_density : hint_range(0.0, 1.0) = 1.0;
uniform float sky_density : hint_range(0.0, 1.0) = 1.0;

uniform float region_z_center = 5.0;
uniform float region_z_extent = 55.0;

uniform int region_count = 0;
uniform vec4 region_bounds[32];
uniform vec4 region_params[32];


float sdf_box(vec3 point, vec3 centre, vec3 half_extents) {
	vec3 q = abs(point - centre) - half_extents;
	return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}


void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}


void fragment() {
	float begin = plane_depth + fog_near_offset;
	float end = plane_depth + fog_far_offset;

	float raw = texture(depth_texture, SCREEN_UV).r;
	bool is_sky = raw <= 0.0;

	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, raw);
	vec4 clip = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float safe_w = abs(clip.w) < 1e-9 ? 1e-9 : clip.w;
	vec3 view_pos = clip.xyz / safe_w;
	float linear_depth = is_sky ? end : -view_pos.z;
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(view_pos, 1.0)).xyz;

	float t = clamp((linear_depth - begin) / max(end - begin, 1e-4), 0.0, 1.0);
	float ramp = pow(t, max(depth_curve, 1e-4));
	ramp = mix(ramp, 1.0, clamp(forefront, 0.0, 1.0));
	if (is_sky) {
		ramp = sky_density;
	}

	float reveal = 0.0;
	if (!is_sky) {
		for (int i = 0; i < region_count; i++) {
			vec4 b = region_bounds[i];
			vec4 p = region_params[i];
			float sd = sdf_box(world_pos,
					vec3(b.xy, region_z_center),
					vec3(b.zw, region_z_extent));
			reveal = max(reveal, p.y * (1.0 - smoothstep(0.0, max(p.x, 1e-4), sd)));
		}
	}

	float density = clamp(max_density * ramp * (1.0 - reveal), 0.0, 1.0);

	ALBEDO = fog_color.rgb;
	ALPHA = density * fog_color.a;
}
