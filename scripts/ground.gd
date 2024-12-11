extends XRToolsPickable

@export var noiseTexture: NoiseTexture2D

var rd: RenderingDevice
var pipeline: RID
var uniform_set: RID

var viewport_texture_rid: RID

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
	
	var noise_image: Image = noiseTexture.get_image()
	var memory_initial_data = PackedFloat32Array()
	memory_initial_data.resize(512 * 512)
	for y in range(512):
		for x in range(512):
			memory_initial_data.set(y * 512 + x, noise_image.get_pixel(x, y).r)

	var memory_format = RDTextureFormat.new()
	memory_format.array_layers = 1
	memory_format.width = 512
	memory_format.height = 512
	memory_format.usage_bits = RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	memory_format.format = RenderingDevice.DATA_FORMAT_R32_SFLOAT

	memory_texture_rid = rd.texture_create(memory_format, RDTextureView.new(), [memory_initial_data.to_byte_array()])

	var viewport_uniform = RDUniform.new()
	viewport_uniform.binding = 0
	viewport_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	viewport_uniform.add_id(viewport_texture_rid)

	var memory_uniform = RDUniform.new()
	memory_uniform.binding = 1
	memory_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	memory_uniform.add_id(memory_texture_rid)

	uniform_set = rd.uniform_set_create([viewport_uniform, memory_uniform], shader, 0)

	memory_texture = Texture2DRD.new()
	memory_texture.set_texture_rd_rid(memory_texture_rid)
	$ground.get_active_material(0).set_shader_parameter("memoryTexture", memory_texture)

func _render_process() -> void:
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, 512 / 8, 512 / 8, 1)
	rd.compute_list_end()
	
	var heightmap: HeightMapShape3D = $CollisionShape3D.shape
	heightmap.update_map_data_from_image(memory_texture.get_image(), 0.0, 1.0)

func _ready() -> void:
	await noiseTexture.changed
	RenderingServer.call_on_render_thread(_render_ready)

func _process(delta: float) -> void:
	RenderingServer.call_on_render_thread(_render_process)
