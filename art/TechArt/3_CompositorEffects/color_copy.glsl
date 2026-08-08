#[compute]
#version 450

// notes
// copy the colour buffer into a sampleable texture for CompositorEffectBase before distortion effects 
// internal color buffer lacks TEXTURE_USAGE_CAN_COPY_FROM_BIT and cannot be copied/transfered

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform readonly image2D src_image;
layout(rgba16f, set = 0, binding = 1) uniform writeonly image2D dst_image;

layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	vec2 pad;
} params;

void main() {
	ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(params.raster_size);
	if (pos.x >= size.x || pos.y >= size.y) {
		return;
	}
	imageStore(dst_image, pos, imageLoad(src_image, pos));
}
