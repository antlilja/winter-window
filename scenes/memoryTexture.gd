extends Node3D

@export var noiseTexture: NoiseTexture2D

var memoryImage: Image
var memoryTexture: ImageTexture
@onready var viewportTexture = $ground.material_override.get_shader_parameter("viewportTexture")

func _ready() -> void:
	await noiseTexture.changed
	var noiseImage = noiseTexture.get_image()
	memoryImage = Image.create(noiseImage.get_width(), noiseImage.get_height(), false, noiseImage.get_format())
	memoryImage.copy_from(noiseTexture.get_image())
	
	memoryTexture = ImageTexture.create_from_image(memoryImage)
	$ground.get_active_material(0).set_shader_parameter("memoryTexture", memoryTexture)

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
			var viewportPixel = viewportImage.get_pixel(x,y)
			var memoryValue= memoryImage.get_pixel(x,y).r
			
			# Deforms new snow
			if viewportPixel.r != 0.0 && memoryValue > viewportPixel.r:
				memoryImage.set_pixel(x, y, viewportPixel)
	memoryTexture.update(memoryImage)
