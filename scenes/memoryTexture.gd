@tool
extends Node3D

var imageTexture
@onready var viewportTexture = $ground.get_instance_shader_parameter("viewportTexture")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	imageTexture = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	for x in range(512):
		for y in range(512):
			imageTexture.set_pixel(x, y, 0)
	$ground.set_instance_shader_parameter("memoryTexture", imageTexture)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(viewportTexture.get_size())
	#for x in range(512):
		#for y in range(512):
			#if data.get_pixel(x,y) != Color(0, 0, 0, 1):
			#	imageTexture.set_pixel(x, y, data.get_pixel(x,y))
	$ground.set_instance_shader_parameter("memoryTexture", imageTexture)
