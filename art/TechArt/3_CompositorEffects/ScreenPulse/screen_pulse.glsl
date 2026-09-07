#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;
layout(set = 1, binding = 0) uniform sampler2D screen_tex;

layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	float time;
	float base_strength;
	float pulse_strength;
	float pulse_speed;
	float focus_radius;
	float pad;
} params;

void main() {
	ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(params.raster_size);
	if (pos.x >= size.x || pos.y >= size.y) {
		return;
	}

	vec2 uv = (vec2(pos) + 0.5) / params.raster_size;
	vec2 centered = uv - vec2(0.5);
	float dist = length(centered);
	float pulse = 0.5 + 0.5 * sin(params.time * params.pulse_speed);
	float strength = params.base_strength + pulse * params.pulse_strength;
	float center_mask = 1.0 - smoothstep(0.0, params.focus_radius, dist);
	strength *= center_mask;

	vec2 warped_uv = uv - centered * strength; // not normalized

	float a = imageLoad(color_image, pos).a;
	imageStore(color_image, pos, vec4(texture(screen_tex, warped_uv).rgb, a));
}
