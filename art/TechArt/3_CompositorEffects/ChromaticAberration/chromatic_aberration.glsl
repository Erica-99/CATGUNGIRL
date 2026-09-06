#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;
layout(set = 1, binding = 0) uniform sampler2D screen_tex;

layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	vec2 r_displacement;
	vec2 g_displacement;
	vec2 b_displacement;
} params;

void main() {
	ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(params.raster_size);
	if (pos.x >= size.x || pos.y >= size.y) {
		return;
	}

	vec2 pixel_size = 1.0 / params.raster_size;
	vec2 uv = (vec2(pos) + 0.5) * pixel_size;

	float r = texture(screen_tex, uv + pixel_size * params.r_displacement).r;
	float g = texture(screen_tex, uv + pixel_size * params.g_displacement).g;
	float b = texture(screen_tex, uv + pixel_size * params.b_displacement).b;
	float a = imageLoad(color_image, pos).a;

	imageStore(color_image, pos, vec4(r, g, b, a));
}
