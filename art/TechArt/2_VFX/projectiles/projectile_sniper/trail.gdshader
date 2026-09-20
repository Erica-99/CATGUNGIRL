shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 core_color : source_color = vec4(1.0, 0.8, 0.45, 1.0);
uniform float intensity = 3.0;
uniform float edge_softness = 1.5;
uniform float core_width = 0.25;

void fragment() {
	float across = abs(UV.y * 2.0 - 1.0);
	float edge = pow(clamp(1.0 - across, 0.0, 1.0), edge_softness);
	float core = smoothstep(core_width, 0.0, across);
	ALBEDO = mix(COLOR.rgb, core_color.rgb, core * COLOR.a) * intensity;
	ALPHA = clamp(edge * COLOR.a, 0.0, 1.0);
}
