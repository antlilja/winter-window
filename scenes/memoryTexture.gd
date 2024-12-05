#@tool
extends Node3D

var image
var regen = 2.0
var time = 0.0
@onready var viewportTexture = $ground.material_override.get_shader_parameter("viewportTexture")
var memTexture
var playSound = true
var timeToNextSound = 0
@onready var footsteps = $AudioStreamPlayer3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mat = $ground.get_active_material(0)
	image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	for x in range(512):
		for y in range(512):
			image.set_pixel(x, y, 0)
			
	if mat is ShaderMaterial:
		var texture = ImageTexture.create_from_image(image)
		mat.set_shader_parameter("memoryTexture", texture)
		memTexture = texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	viewportTexture = $ground.material_override.get_shader_parameter("viewportTexture")
	memTexture = $ground.material_override.get_shader_parameter("memoryTexture")
	var data = viewportTexture.get_image()
	var memData = memTexture.get_image()
	for x in range(512):
		
		for y in range(512):
			var pixel = data.get_pixel(x,y)
			var memPixel = memData.get_pixel(x,y)
			
			var snowAmount = 0.1
			
			# Deforms new snow
			if pixel != Color(0, 0, 0, 1):
				image.set_pixel(x, y, pixel)
				if playSound and memPixel != pixel:
					footsteps.play()
					timeToNextSound = 1.0
					playSound = false
				
	#		var newPixel = memPixel
			#Check previous snow and check if it should regenerate
	#		if time > regen:
	#			if newPixel.r - snowAmount > 0:
	#				newPixel.r = newPixel.r - snowAmount
	#				newPixel.b = newPixel.r - snowAmount
	#				newPixel.g = newPixel.r - snowAmount
	#			else:
	#				newPixel.r = 0
	#				newPixel.b = 0
	#				newPixel.g = 0
	#				
	#			image.set_pixel(x, y, newPixel)
	
	#if (time > regen):
	#	time = 0.0
	var texture = ImageTexture.create_from_image(image)
	$ground.material_override.set_shader_parameter("memoryTexture", texture)
	#print($ground.material_override.get_shader_parameter("memoryTexture"))	
	timeToNextSound -= delta
	if timeToNextSound <= 0:
		playSound = true
