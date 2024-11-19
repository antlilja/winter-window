extends Node3D

@onready var texture_rect = $TextureRect

var rd := RenderingServer.create_local_rendering_device()

var shader_file := load("res://shaders/convert_depth.glsl")
var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
var shader := rd.shader_create_from_spirv(shader_spirv)
var pipeline := rd.compute_pipeline_create(shader)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RealSense.open()
	
	var image = Image.create(1920, 1080, false, Image.Format.FORMAT_RGB8)
	image.fill(Color.RED)
	texture_rect.texture.set_image(image)

func _notification(what: int) -> void:
	if (what == NOTIFICATION_PREDELETE):
		RealSense.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	RealSense.poll_frame()
	#var data = RealSense.get_colour_image()
	#var image = Image.create_from_data(1920, 1080, false, Image.Format.FORMAT_RGB8, data)
	var depth_data = RealSense.get_depth_image()

	var buffer := rd.storage_buffer_create(848 * 480 * 2, depth_data)
	var buffer_out := rd.storage_buffer_create(848 * 480 * 4)
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0
	uniform.add_id(buffer)
	var uniform2 := RDUniform.new()
	uniform2.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform2.binding = 1
	uniform2.add_id(buffer_out)
	var uniform_set := rd.uniform_set_create([uniform, uniform2], shader, 0) # the last parameter (the 0) 
	
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, 848, 480, 1)
	rd.compute_list_end()
	
	rd.submit()
	rd.sync()
	
	var output_bytes := rd.buffer_get_data(buffer_out)
	var image = Image.create_from_data(848, 480, false, Image.Format.FORMAT_RF, output_bytes)
	texture_rect.texture.set_image(image)
