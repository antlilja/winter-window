extends XRToolsPickable

@export var noise: FastNoiseLite
@export var snow_regen_rate: float = 0.01

var rd: RenderingDevice
var pipeline: RID
var uniform_set: RID

var viewport_width: int
var viewport_height: int
var viewport_texture_rid: RID

var noise_texture_rid: RID
var noise_texture: Texture2DRD

var memory_texture_rid: RID
var memory_texture: Texture2DRD

func _render_ready() -> void:
	rd = RenderingServer.get_rendering_device()

	var shader_file = load("res://shaders/snow_deform.glsl")
	var shader_spriv: RDShaderSPIRV = shader_file.get_spirv()
	var shader = rd.shader_create_from_spirv(shader_spriv)
	pipeline = rd.compute_pipeline_create(shader)

	var subviewport: SubViewport = $SubViewport
	subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	viewport_texture_rid = RenderingServer.texture_get_rd_texture(subviewport.get_texture().get_rid())

	var viewport_format = rd.texture_get_format(viewport_texture_rid)
	viewport_width = viewport_format.width
	viewport_height = viewport_format.height

	var noise_image: Image = noise.get_image(viewport_width, viewport_height, false, false, true)
	var noise_data = PackedFloat32Array()
	noise_data.resize(noise_image.get_width() * noise_image.get_height())
	for y in range(noise_image.get_width()):
		for x in range(noise_image.get_height()):
			noise_data.set(y * noise_image.get_width() + x, noise_image.get_pixel(x, y).r)

	var memory_format = RDTextureFormat.new()
	memory_format.array_layers = 1
	memory_format.width = viewport_width
	memory_format.height = viewport_height
	memory_format.usage_bits = RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	memory_format.format = RenderingDevice.DATA_FORMAT_R32_SFLOAT

	noise_texture_rid = rd.texture_create(memory_format, RDTextureView.new(), [noise_data.to_byte_array()])

	memory_texture_rid = rd.texture_create(memory_format, RDTextureView.new(), [noise_data.to_byte_array()])
	memory_texture = Texture2DRD.new()
	memory_texture.set_texture_rd_rid(memory_texture_rid)
	$SnowMesh.get_active_material(0).set_shader_parameter("memoryTexture", memory_texture)

	var viewport_uniform = RDUniform.new()
	viewport_uniform.binding = 0
	viewport_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	viewport_uniform.add_id(viewport_texture_rid)

	var noise_uniform = RDUniform.new()
	noise_uniform.binding = 1
	noise_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	noise_uniform.add_id(noise_texture_rid)

	var memory_uniform = RDUniform.new()
	memory_uniform.binding = 2
	memory_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	memory_uniform.add_id(memory_texture_rid)

	uniform_set = rd.uniform_set_create([viewport_uniform, noise_uniform, memory_uniform], shader, 0)

func _render_process(delta: float) -> void:
	var buffer = PackedFloat32Array()
	buffer.append(delta)
	buffer.append(snow_regen_rate)
	buffer.append(0)
	buffer.append(0)

	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_set_push_constant(compute_list, buffer.to_byte_array(), 16)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, viewport_width, viewport_height, 1)
	rd.compute_list_end()

	var heightmap: HeightMapShape3D = $CollisionShape3D.shape
	heightmap.update_map_data_from_image(memory_texture.get_image(), 0.0, 1.0)

func _ready() -> void:
	RenderingServer.call_on_render_thread(_render_ready)

func _process(delta: float) -> void:
	RenderingServer.call_on_render_thread(_render_process.bind(delta))
