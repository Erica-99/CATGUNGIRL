shader_type spatial;
render_mode unshaded, blend_mix, cull_front, depth_draw_never;

uniform sampler2D color_tex : source_color, repeat_enable, hint_default_white;
uniform vec4 color_uv = vec4(1.0, 1.0, 0.0, 0.0);
uniform vec4 color_speed = vec4(1.0, 0.0, 0.0, 0.0);
uniform vec4 light_color : source_color = vec4(1.0, 0.92775, 0.6462264, 1.0);
uniform vec4 dark_color : source_color = vec4(0.1509434, 0.07064492, 0.03203988, 1.0);
uniform float contrast : hint_range(0.45, 3.0) = 1.0;
uniform vec4 tint : source_color = vec4(1.0);
uniform float color_power : hint_range(0.0, 4.0) = 1.0;

uniform sampler2D wpo_tex : source_color, repeat_enable, hint_default_white;
uniform vec4 wpo_uv = vec4(1.0, 1.0, 0.0, 0.0);
uniform vec4 wpo_speed = vec4(1.0, 0.0, 0.0, 0.0);
uniform float wpo_power : hint_range(0.0, 0.1) = 0.0;
uniform float wpo_contrast : hint_range(0.45, 3.0) = 1.0;
uniform float outline_width : hint_range(0.0, 0.1) = 0.0036;

void vertex() {
	vec4 clip_pos = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec2 screen_uv = clip_pos.xy / clip_pos.w * 0.5 + 0.5;
	vec2 uv = screen_uv * wpo_uv.xy + wpo_uv.zw + TIME * wpo_speed.z * wpo_speed.xy;
	float wpo = pow(textureLod(wpo_tex, uv, 0.0).r, wpo_contrast) * wpo_power;
	VERTEX += (outline_width + wpo) * NORMAL;
}

void fragment() {
	vec2 uv = SCREEN_UV * color_uv.xy + color_uv.zw + TIME * color_speed.z * color_speed.xy;
	float ramp = pow(texture(color_tex, uv).r, contrast);
	ALBEDO = mix(dark_color, light_color, ramp).rgb * color_power * tint.rgb;
	ALPHA = 1.0;
}
