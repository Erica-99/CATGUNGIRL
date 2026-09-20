shader_type spatial;
render_mode unshaded, fog_disabled, depth_draw_never;
stencil_mode read, compare_not_equal, 2;

struct ScreenPosition {
	vec2 ViewportUV;
	vec2 PixelPosition;
};

uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler2D screen_texture : hint_screen_texture;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_thickness = 2.0;
uniform float edge_threshold = 0.2;
uniform float edge_smoothness = 0.5;
uniform float depth_threshold = 0.1;
uniform float depth_smoothness = 0.1;
uniform float outline_intensity = 0.65;
uniform float color_cycle_speed = 0.0;
uniform int debug_view : hint_enum(
	"Off", 
	"World Normals", 
	"Normal Edge Raw", 
	"Normal Mask", 
	"Depth Edge Raw", 
	"Depth Mask", 
	"Final Mask"
	) = 0;

vec3 reconstructWorldPosition(float depth, vec2 screen_uv, mat4 inv_proj, mat4 inv_view) {
	vec4 world_pos = inv_view * (inv_proj * vec4(screen_uv * 2.0 - 1.0, depth, 1.0));
	return world_pos.xyz / world_pos.w;
}

vec3 reconstructWorldNormal(sampler2D depth_tex, vec2 screen_uv, mat4 inv_proj, mat4 inv_view, vec2 viewport_size) {
    vec2 e = vec2(1.0 / viewport_size);
    float c0 = texture(depth_tex, screen_uv                ).r;
    float l2 = texture(depth_tex, screen_uv - vec2(2,0) * e).r;
    float l1 = texture(depth_tex, screen_uv - vec2(1,0) * e).r;
    float r1 = texture(depth_tex, screen_uv + vec2(1,0) * e).r;
    float r2 = texture(depth_tex, screen_uv + vec2(2,0) * e).r;
    float b2 = texture(depth_tex, screen_uv - vec2(0,2) * e).r;
    float b1 = texture(depth_tex, screen_uv - vec2(0,1) * e).r;
    float t1 = texture(depth_tex, screen_uv + vec2(0,1) * e).r;
    float t2 = texture(depth_tex, screen_uv + vec2(0,2) * e).r;
    
    float dl = abs(l1 * l2 / (2.0 * l2 - l1) - c0);
    float dr = abs(r1 * r2 / (2.0 * r2 - r1) - c0);
    float db = abs(b1 * b2 / (2.0 * b2 - b1) - c0);
    float dt = abs(t1 * t2 / (2.0 * t2 - t1) - c0);
    
    vec3 ce = reconstructWorldPosition(c0, screen_uv, inv_proj, inv_view);

    vec3 dpdx = (dl<dr) ?  ce-reconstructWorldPosition(l1, screen_uv - vec2(1,0) * e, inv_proj, inv_view) :
                          -ce+reconstructWorldPosition(r1, screen_uv + vec2(1,0) * e, inv_proj, inv_view) ;
    vec3 dpdy = (db<dt) ?  ce-reconstructWorldPosition(b1, screen_uv - vec2(0,1) * e, inv_proj, inv_view) :
                          -ce+reconstructWorldPosition(t1, screen_uv + vec2(0,1) * e, inv_proj, inv_view) ;

    return normalize(cross(dpdx,dpdy));
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

vec3 sampleWorldNormal(vec2 screen_uv, mat4 inv_proj, mat4 inv_view, vec2 viewport_size) {
	vec3 n = reconstructWorldNormal(depth_texture, screen_uv, inv_proj, inv_view, viewport_size);
	return n * 0.5 + 0.5;
}

float sampleLinearDepth(vec2 screen_uv, mat4 inv_proj) {
	float depth = texture(depth_texture, screen_uv).r;
	vec4 view = inv_proj * vec4(screen_uv * 2.0 - 1.0, depth, 1.0);
	return -view.z / view.w;
}

void fragment() {
	vec2 texel = outline_thickness / VIEWPORT_SIZE.xy;
	vec2 tl = SCREEN_UV + vec2(-1.0, 1.0) * texel;
	vec2 br = SCREEN_UV + vec2(1.0, -1.0) * texel;
	vec2 tr = SCREEN_UV + vec2(1.0, 1.0) * texel;
	vec2 bl = SCREEN_UV + vec2(-1.0, -1.0) * texel;

	vec3 n_c = sampleWorldNormal(SCREEN_UV, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX, VIEWPORT_SIZE.xy);
	vec3 n_tl = sampleWorldNormal(tl, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX, VIEWPORT_SIZE.xy);
	vec3 n_br = sampleWorldNormal(br, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX, VIEWPORT_SIZE.xy);
	vec3 n_tr = sampleWorldNormal(tr, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX, VIEWPORT_SIZE.xy);
	vec3 n_bl = sampleWorldNormal(bl, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX, VIEWPORT_SIZE.xy);

	vec3 cross_diff = abs(n_tl - n_br) + abs(n_tr - n_bl);
	vec3 center_diff = max(
		max(abs(n_c - n_tl), abs(n_c - n_br)),
		max(abs(n_c - n_tr), abs(n_c - n_bl)));
	vec3 edge = max(cross_diff, center_diff);
	float edge_strength = max(edge.r, max(edge.g, edge.b));
	float normal_mask = smoothstep(edge_threshold, edge_threshold + edge_smoothness, edge_strength);

	float d_tl = sampleLinearDepth(tl, INV_PROJECTION_MATRIX);
	float d_br = sampleLinearDepth(br, INV_PROJECTION_MATRIX);
	float d_tr = sampleLinearDepth(tr, INV_PROJECTION_MATRIX);
	float d_bl = sampleLinearDepth(bl, INV_PROJECTION_MATRIX);

	float depth_diff = abs(d_tl - d_br) + abs(d_tr - d_bl);
	float max_depth = max(max(d_tl, d_br), max(d_tr, d_bl));
	float depth_strength = clamp(depth_diff / max_depth, 0.0, 1.0);
	float depth_mask = smoothstep(depth_threshold, depth_threshold + depth_smoothness, depth_strength);

	float mask = max(normal_mask, depth_mask) * outline_intensity;

	vec3 scene = texture(screen_texture, SCREEN_UV).rgb;

	vec3 line_color = outline_color.rgb;
	if (color_cycle_speed > 0.0) {
		line_color = 0.5 + 0.5 * sin(TIME * color_cycle_speed * vec3(1.0, 1.31, 1.73) + vec3(0.0, 2.09, 4.19));
	}

	switch (debug_view) {
		case 1:
			ALBEDO = n_c;
			break;
		case 2:
			ALBEDO = vec3(edge_strength);
			break;
		case 3:
			ALBEDO = vec3(normal_mask);
			break;
		case 4:
			ALBEDO = vec3(depth_strength);
			break;
		case 5:
			ALBEDO = vec3(depth_mask);
			break;
		case 6:
			ALBEDO = vec3(mask);
			break;
		default:
			ALBEDO = mix(scene, line_color, mask * outline_color.a);
			break;
	}
}
