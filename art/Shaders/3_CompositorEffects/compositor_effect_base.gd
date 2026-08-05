@tool
class_name CompositorEffectBase
extends CompositorEffect

## Subclasses override _get_shader_path(), _get_push_constant() and, for
## effects that sample arbitrary UVs (distortion), _needs_color_copy().
##
## Shader contract (see ChromaticAberration/chromatic_aberration.glsl):
##   set 0, binding 0: rgba16f image2D  — the color buffer (read/write)
##   set 1, binding 0: sampler2D       — pre-pass copy, only when _needs_color_copy()
##   push constant: floats from _get_push_constant(), padded to 16 bytes;
##                  first two floats must be the raster size.

const COPY_SHADER_PATH := "res://art/Shaders/3_CompositorEffects/color_copy.glsl"

var rd: RenderingDevice
var shader: RID
var pipeline: RID
var copy_shader: RID
var copy_pipeline: RID
var linear_sampler: RID


func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()
	if rd:
		RenderingServer.call_on_render_thread(_initialize_compute)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and rd:
		if shader.is_valid():
			rd.free_rid(shader) # also frees the pipeline
		if copy_shader.is_valid():
			rd.free_rid(copy_shader)
		if linear_sampler.is_valid():
			rd.free_rid(linear_sampler)


#region Subclass contract

func _get_shader_path() -> String:
	return ""


func _get_push_constant(size: Vector2i) -> PackedFloat32Array:
	return PackedFloat32Array([size.x, size.y, 0.0, 0.0])


func _needs_color_copy() -> bool:
	return false

#endregion


#region Render-thread internals

func _initialize_compute() -> void:
	shader = _load_compute_shader(_get_shader_path())
	if not shader.is_valid():
		return
	pipeline = rd.compute_pipeline_create(shader)

	if _needs_color_copy():
		copy_shader = _load_compute_shader(COPY_SHADER_PATH)
		if not copy_shader.is_valid():
			return
		copy_pipeline = rd.compute_pipeline_create(copy_shader)

	var sampler_state := RDSamplerState.new()
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	sampler_state.repeat_u = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	sampler_state.repeat_v = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	linear_sampler = rd.sampler_create(sampler_state)


func _load_compute_shader(path: String) -> RID:
	var shader_file: RDShaderFile = load(path)
	if not shader_file:
		push_error("CompositorEffectBase: could not load shader: " + path)
		return RID()
	var spirv: RDShaderSPIRV = shader_file.get_spirv()
	if spirv.compile_error_compute != "":
		push_error("CompositorEffectBase: compute compile error in %s:\n%s"
				% [path, spirv.compile_error_compute])
		return RID()
	return rd.shader_create_from_spirv(spirv)


func _render_callback(p_effect_callback_type: int, p_render_data: RenderData) -> void:
	if not rd or not pipeline.is_valid() or p_effect_callback_type != effect_callback_type:
		return
	if _needs_color_copy() and not copy_pipeline.is_valid():
		return
	var buffers: RenderSceneBuffersRD = p_render_data.get_render_scene_buffers()
	if not buffers:
		return
	var size: Vector2i = buffers.get_internal_size()
	if size.x == 0 or size.y == 0:
		return

	var push_constant := _get_push_constant(size)
	while push_constant.size() % 4 != 0: # pad to 16-byte multiple
		push_constant.push_back(0.0)
	var push_bytes := push_constant.to_byte_array()

	@warning_ignore("integer_division")
	var x_groups := (size.x - 1) / 8 + 1
	@warning_ignore("integer_division")
	var y_groups := (size.y - 1) / 8 + 1

	for view in buffers.get_view_count():
		var color_image := buffers.get_color_layer(view)

		var image_uniform := RDUniform.new()
		image_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		image_uniform.binding = 0
		image_uniform.add_id(color_image)
		var image_set := UniformSetCacheRD.get_cache(shader, 0, [image_uniform])

		var compute_list := rd.compute_list_begin()

		if _needs_color_copy():
			# The internal color buffer lacks CAN_COPY_FROM, so blit it into a
			# sampleable texture with a compute pass instead of texture_copy().
			var copy_image := buffers.create_texture(
					_copy_context(), StringName("color_copy_%d" % view),
					RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT,
					RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
					| RenderingDevice.TEXTURE_USAGE_STORAGE_BIT,
					RenderingDevice.TEXTURE_SAMPLES_1,
					size, 1, 1, true, false)
			var src_uniform := RDUniform.new()
			src_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
			src_uniform.binding = 0
			src_uniform.add_id(color_image)
			var dst_uniform := RDUniform.new()
			dst_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
			dst_uniform.binding = 1
			dst_uniform.add_id(copy_image)
			var blit_set := UniformSetCacheRD.get_cache(copy_shader, 0, [src_uniform, dst_uniform])
			var blit_push := PackedFloat32Array([size.x, size.y, 0.0, 0.0]).to_byte_array()

			rd.compute_list_bind_compute_pipeline(compute_list, copy_pipeline)
			rd.compute_list_bind_uniform_set(compute_list, blit_set, 0)
			rd.compute_list_set_push_constant(compute_list, blit_push, blit_push.size())
			rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
			rd.compute_list_add_barrier(compute_list)

			var sampler_uniform := RDUniform.new()
			sampler_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
			sampler_uniform.binding = 0
			sampler_uniform.add_id(linear_sampler)
			sampler_uniform.add_id(copy_image)
			var sampled_set := UniformSetCacheRD.get_cache(shader, 1, [sampler_uniform])
			rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
			rd.compute_list_bind_uniform_set(compute_list, image_set, 0)
			rd.compute_list_bind_uniform_set(compute_list, sampled_set, 1)
		else:
			rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
			rd.compute_list_bind_uniform_set(compute_list, image_set, 0)

		rd.compute_list_set_push_constant(compute_list, push_bytes, push_bytes.size())
		rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
		rd.compute_list_end()


# Unique context per effect instance so chained effects never share copy textures.
func _copy_context() -> StringName:
	return StringName("CompositorEffectBase_%d" % get_instance_id())

#endregion
