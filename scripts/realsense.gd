extends Node3D

@onready var mesh = $MeshInstance3D

var rd := RenderingServer.create_local_rendering_device()

var shader_file := load("res://shaders/convert_depth.glsl")
var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
var shader := rd.shader_create_from_spirv(shader_spirv)
var pipeline := rd.compute_pipeline_create(shader)
var buffer_in := rd.storage_buffer_create(1280 * 720 * 2)
var buffer_out := rd.storage_buffer_create(1280 * 720 * 4)

var uniform_set: RID
var colour_image: Image
var colour_texture: ImageTexture
var depth_image: Image
var depth_texture: ImageTexture
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
	uniform_set = rd.uniform_set_create([uniform, uniform2], shader, 0)
	
	material = mesh.get_active_material(0)
	
	colour_image = Image.create(1280, 720, false, Image.Format.FORMAT_RGB8)
	colour_texture = ImageTexture.create_from_image(colour_image)
	material.set_shader_parameter("colour_texture", colour_texture) 
	
	depth_image = Image.create(1280, 720, false, Image.Format.FORMAT_RF)
	depth_texture = ImageTexture.create_from_image(depth_image)
	material.set_shader_parameter("depth_texture", depth_texture) 


func _notification(what: int) -> void:
	if (what == NOTIFICATION_PREDELETE):
		RealSense.close()
		rd.free_rid(buffer_out)
		rd.free_rid(buffer_in)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("enable_camera"):
		mesh.visible = !mesh.visible
	
	if Input.is_action_just_pressed("ui_accept"):
		material.set_shader_parameter("show_depth", !material.get_shader_parameter("show_depth"))

	if RealSense.poll_frame():
		rd.buffer_update(buffer_in, 0, 1280 * 720 * 2, RealSense.get_depth_image())
		
		var compute_list := rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
		rd.compute_list_dispatch(compute_list, 1280, 720, 1)
		rd.compute_list_end()
		
		rd.submit()
		rd.sync()
		
		colour_image.set_data(1280, 720, false, Image.Format.FORMAT_RGB8, RealSense.get_colour_image())
		colour_texture.update(colour_image)
		
		var output_bytes := rd.buffer_get_data(buffer_out)
		depth_image.set_data(1280, 720, false, Image.Format.FORMAT_RF, output_bytes)
		depth_texture.update(depth_image)
