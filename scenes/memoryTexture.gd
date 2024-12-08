extends Node3D

var image: Image
var texture: ImageTexture
@onready var viewportTexture = $ground.material_override.get_shader_parameter("viewportTexture")

func _ready() -> void:
	image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	image.fill(Color.BLACK)
	
	var mat = $ground.get_active_material(0)
	if mat is ShaderMaterial:
		texture = ImageTexture.create_from_image(image)
		mat.set_shader_parameter("memoryTexture", texture)

func reset_deformation() -> void:
	for x in range(512):
		for y in range(512):
			image.set_pixel(x, y, 0)
	var texture = ImageTexture.create_from_image(image)
	$ground.material_override.set_shader_parameter("memoryTexture", texture)

func _process(delta: float) -> void:
	var viewportImage = viewportTexture.get_image()
	for x in range(512):
		for y in range(512):
			var pixel = viewportImage.get_pixel(x,y)
			var memPixel = image.get_pixel(x,y)
			
			# Deforms new snow
			if pixel != Color(0, 0, 0, 1):
				image.set_pixel(x, y, pixel)
	texture.update(image)
