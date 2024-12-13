extends Node3D

@onready var mesh = $MeshInstance3D

var material: Material

func _render_ready() -> void:
	RealSense.open()
	
	material = mesh.get_active_material(0)
	material.set_shader_parameter("colour_texture", RealSense.get_colour_texture())
	material.set_shader_parameter("depth_texture", RealSense.get_depth_texture())

func _render_close() -> void:
	RealSense.close()

func _render_process() -> void:
	RealSense.process_frame()

func _ready() -> void:
	RenderingServer.call_on_render_thread(_render_ready)

func _notification(what: int) -> void:
	if (what == NOTIFICATION_PREDELETE):
		RenderingServer.call_on_render_thread(_render_close)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("enable_camera"):
		mesh.visible = !mesh.visible
	
	if Input.is_action_just_pressed("ui_accept"):
		material.set_shader_parameter("show_depth", !material.get_shader_parameter("show_depth"))

	RenderingServer.call_on_render_thread(_render_process)
