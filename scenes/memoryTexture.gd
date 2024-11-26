#@tool
extends Node3D

var image
@onready var viewportTexture = $ground.material_override.get_shader_parameter("viewportTexture")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mat = $ground.get_active_material(0)
	print(mat)
	image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	for x in range(512):
		for y in range(512):
			image.set_pixel(x, y, 0)
			
	if mat is ShaderMaterial:
		var texture = ImageTexture.create_from_image(image)
		mat.set_shader_parameter("memoryTexture", texture)
		print("Applied texture: ")
		print(mat.get_shader_parameter("memoryTexture"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var data = viewportTexture.get_image()
	for x in range(512):
		for y in range(512):
			if data.get_pixel(x,y) != Color(0, 0, 0, 1):
				image.set_pixel(x, y, data.get_pixel(x,y))
	var texture = ImageTexture.create_from_image(image)
	$ground.material_override.set_shader_parameter("memoryTexture", texture)
	#print($ground.material_override.get_shader_parameter("memoryTexture"))	
