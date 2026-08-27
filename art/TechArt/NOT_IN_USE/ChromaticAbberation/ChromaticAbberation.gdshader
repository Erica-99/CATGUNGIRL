shader_type spatial;
render_mode unshaded, fog_disabled;

uniform int levels = 3;
uniform float spread = 0.01;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex(){
	// Pin the quad to the full screen at the near plane (Godot 4.3+ reversed-Z).
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment(){
	vec3 sum = vec3(0.0);
	vec3 col = vec3(0.0);
	vec2 offset = SCREEN_UV - vec2(0.5);
	for(int i = 0; i < levels; i++){
		float t = 2.0*float(i)/float(levels-1); // range 0.0->2.0
		vec3 slice = vec3(1.0-t, 1.0 - abs(t - 1.0), t - 1.0);
		slice = max(slice, 0.0);
		sum += slice;
		vec2 slice_offset = (t-1.0)*spread*offset;
		col += slice * texture(SCREEN_TEXTURE, SCREEN_UV + slice_offset).rgb;
	}
	ALBEDO = col / sum;
}
