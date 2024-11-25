@tool
extends Node3D

var imageTexture
@onready var viewportTexture = $ground.material_override.get_shader_parameter("viewportTexture")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	imageTexture = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	for x in range(512):
		for y in range(512):
			imageTexture.set_pixel(x, y, 0)
	$ground.material_override.set_shader_parameter("memoryTexture", imageTexture)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var data = viewportTexture.get_image()
	for x in range(512):
		for y in range(512):
			if data.get_pixel(x,y) != Color(0, 0, 0, 1):
				imageTexture.set_pixel(x, y, data.get_pixel(x,y))
	$ground.material_override.set_shader_parameter("memoryTexture", imageTexture)
