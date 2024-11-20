extends Node3D

@onready var mesh = $MeshInstance3D

var rd := RenderingServer.create_local_rendering_device()

var shader_file := load("res://shaders/convert_depth.glsl")
var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
var shader := rd.shader_create_from_spirv(shader_spirv)
var pipeline := rd.compute_pipeline_create(shader)
var buffer_in := rd.storage_buffer_create(848 * 480 * 2)
var buffer_out := rd.storage_buffer_create(848 * 480 * 4)

var uniform_set: RID
var colour_image: Image
var depth_image: Image
var material: Material

func _ready() -> void:
	RealSense.open()
	
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0
	uniform.add_id(buffer_in)
	var uniform2 := RDUniform.new()
	uniform2.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform2.binding = 1
	uniform2.add_id(buffer_out)
	uniform_set = rd.uniform_set_create([uniform, uniform2], shader, 0) # the last parameter (the 0) 
	
	colour_image = Image.create(1920, 1080, false, Image.Format.FORMAT_RGB8)
	depth_image = Image.create(848, 480, false, Image.Format.FORMAT_RF)
	
	material = mesh.get_active_material(0)

func _notification(what: int) -> void:
	if (what == NOTIFICATION_PREDELETE):
		RealSense.close()
		rd.free_rid(buffer_out)
		rd.free_rid(buffer_in)

func _process(delta: float) -> void:
	if RealSense.poll_frame():
		rd.buffer_update(buffer_in, 0, 848 * 480 * 2, RealSense.get_depth_image())
		
		var compute_list := rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
		rd.compute_list_dispatch(compute_list, 848, 480, 1)
		rd.compute_list_end()
		
		rd.submit()
		
		colour_image.set_data(1920, 1080, false, Image.Format.FORMAT_RGB8, RealSense.get_colour_image())
		var colour_texture = ImageTexture.create_from_image(colour_image)
		material.set_shader_parameter("colour_texture", colour_texture) 
		
		rd.sync()
		var output_bytes := rd.buffer_get_data(buffer_out)
		var float_data = output_bytes.to_float32_array();
		print(float_data[848 * 240 + 424])
		depth_image.set_data(848, 480, false, Image.Format.FORMAT_RF, output_bytes)
		var depth_texture = ImageTexture.create_from_image(depth_image)
		material.set_shader_parameter("depth_texture", depth_texture) 
